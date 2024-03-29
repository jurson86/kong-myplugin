local timestamp = require "kong.tools.timestamp"
local reports = require "kong.reports"
local redis = require "resty.redis"

local kong = kong
local pairs = pairs
local null = ngx.null
local fmt = string.format

local EMPTY_UUID = "00000000-0000-0000-0000-000000000000"


local sock_opts = {}

local function is_present(str)
  return str and str ~= "" and str ~= null
end

return {

  ["redis"] = {
      increment = function(conf)

      local red = redis:new()
      red:set_timeout(conf.redis_timeout)
      -- use a special pool name only if redis_database is set to non-zero
      -- otherwise use the default pool name host:port
      sock_opts.pool = conf.redis_database and
                       conf.redis_host .. ":" .. conf.redis_port ..
                       ":" .. conf.redis_database
      local ok, err = red:connect(conf.redis_host, conf.redis_port,
                                  sock_opts)
      if not ok then
        kong.log.err("failed to connect to Redis: ", err)
        return nil, err
      end

      local times, err = red:get_reused_times()
      if err then
        kong.log.err("failed to get connect reused times: ", err)
        return nil, err
      end

      -- kong.log.err("connect reused times: ", times)
      if times == 0 then
        if is_present(conf.redis_password) then
          local ok, err = red:auth(conf.redis_password)
          if not ok then
            kong.log.err("failed to auth Redis: ", err)
            return nil, err
          end
        end

        if conf.redis_database ~= 0 then
          -- Only call select first time, since we know the connection is shared
          -- between instances that use the same redis database

          local ok, err = red:select(conf.redis_database)
          if not ok then
            kong.log.err("failed to change Redis database: ", err)
            return nil, err
          end
        end

        -- =========================== eg. set data ======================
        local ok, err = red:hmset("myhash", "field1", "Hello", "field2", "World")
        if not ok then
          kong.log.err("failed to set hashmap : ", err)
          return nil, err
        end

      end
      
      -- =======================  eg. multi options  ====================== 
      -- red:init_pipeline()
      -- local ok, err = red:commit_pipeline()
      -- if not ok then
      --  kong.log.err("failed to commit the pipelined requests : ", err)
      --  return nil, err
      -- end
     
      -- kong.log.err("===================== keepalive ================ ")
      local ok, err = red:set_keepalive(10000, 10)
      if not ok then
        kong.log.err("failed to set Redis keepalive: ", err)
        return nil, err
      end

      return true
    end
  }

}
