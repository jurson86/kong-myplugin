package = "kong-plugin-myutils" 
version = "1.0-1" 

local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}

source = {
  url = "...",
  -- tag = "0.1.0"
}

description = {
  summary = "util lua",
  homepage = "http://...",
  license = "MIT"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".myutils"]   = "myutils.lua",
    ["kong.plugins."..pluginName..".myredis"]   = "myredis.lua",
  }
}

