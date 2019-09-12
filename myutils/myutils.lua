local cjson = require "cjson"
local cjson_safe = require "cjson.safe"

local _M={}

-- 对字符串进行分割
function _M.split(str,sp)
    if not str then
       return nil
    end
    local resultStrList = {}
    string.gsub(str,'[^'..sp..']+',function (w)
        if w ~= "" then
          table.insert(resultStrList,w)
        end
    end)
    return resultStrList
end


return _M

