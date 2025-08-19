package = "rapidjson"
version = "0.7.1-2"
local v = version:gsub("%-%d", "")
source = {
  url = "git://github.com/saspivey98/lua-rapidjson/",
  tag = "v"..v
}
description = {
  summary = "A test Fork of Lua-Rapidjson. Json module based on the very fast RapidJSON.",
  detailed = "A json module for Lua 5.1/5.2/5.3 and LuaJIT based on the very fast RapidJSON.",
  homepage = "https://github.com/saspivey98/lua-rapidjson/",
  license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
  type = "cmake",
  variables = {
    BUILD_SHARED_LIBS = "ON",
    CMAKE_INSTALL_PREFIX = "$(PREFIX)",
    LUA_INCLUDE_DIR = "$(LUA_INCDIR)",
    LUA_RAPIDJSON_VERSION = v
  },
  platforms = { windows = { variables = {
    LUA_LIBRARIES = "$(LUA_LIBDIR)/$(LUALIB)"
  }}}
}
