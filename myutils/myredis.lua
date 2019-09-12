local rredis = require("resty.redis")
local cjson = require "cjson"
local utils = require("kong.plugins.myutils.myutils")


local sock_opts = {}

local _M = {}

local function is_present(str)
  return str and str ~= "" and str ~= null
end

local function conn_redis(host,port,conf)
  
      local red = rredis:new()
      red:set_timeout(conf.redis_timeout)

      -- use a special pool name only if database is set to non-zero
      -- otherwise use the default pool name host:port
      sock_opts.pool = conf.redis_database and
                       host .. ":" .. port ..
                       ":" .. conf.redis_database
      local ok, err = red:connect(host, port,
                                  sock_opts)
      if not ok then
        ngx.log(ngx.ERR,"failed to connect to Redis: " , err)
        return nil, err
      end

      local times, err = red:get_reused_times()
      if err then
        ngx.log(ngx.ERR,"failed to get connect reused times: ", err)
        return nil, err
      end
      ngx.log(ngx.INFO,"redis used times: ",times)

      if times == 0 then
        if is_present(conf.redis_password) then
          local ok, err = red:auth(conf.redis_password)
          if not ok then
            ngx.log(ngx.ERR,"failed to auth Redis: ", err)
            return nil, err
          end
        end

        if conf.redis_database ~= 0 then
          -- Only call select first time, since we know the connection is shared
          -- between instances that use the same redis database

          local ok, err = red:select(conf.redis_database)
          if not ok then
            ngx.log(ngx.ERR,"failed to change Redis database: ", err)
            return nil, err
          end
        end

      end
     
      return red
end

function _M.set_keepalive(redis,max_idle_timeout, pool_size)
      -- ngx.log(ngx.ERR,"===================== keepalive ================ ")
      local ok, err = redis:set_keepalive(max_idle_timeout, pool_size)
      if not ok then
        ngx.log(ngx.ERR,"failed to set Redis keepalive: ", err)
        return nil, err
      end
end

--获取redis对象
function _M.get_redis(conf)
  local vredis,err

  if not conf then
   return nil,"redis conf fields: hosts[ip:port,ip:port] , password ,timeout , database"
  end

  local hosts = utils.split(conf.redis_hosts,",")
  for i=1,#hosts do
    local item = hosts[i]
    ngx.log(ngx.ERR,"=====================================redis hosts ==: ",item)
    local host = utils.split(item,":")[1]
    local port = utils.split(item,":")[2] or 6379
    local vredis = conn_redis(host,port,conf)
    if vredis then
      return vredis
    end
  end

  return nil
end

return _M
