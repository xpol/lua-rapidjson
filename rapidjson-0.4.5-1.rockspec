package = "rapidjson"
version = "0.4.5-1"
local v = version:gsub("%-%d", "")
source = {
   url = "git://github.com/xpol/lua-rapidjson",
   tag = "v"..v
}
description = {
   summary = "Very fast json module based on RapidJSON.",
   detailed = [[
        A very fast json module for LuaJIT and Lua 5.1/5.2.

        Based on the very fast json library RapidJSON.

        Provided API:

        - `rapidjson.decode()` decode json to lua table.
        - `rapidjson.encode()` encode lua table to json string.
        - `rapidjson.load()` load json file into lua table.
        - `rapidjson.dump()` dump lua table to json file.
  ]],
   homepage = "https://github.com/xpol/lua-rapidjson",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "cmake",
   platforms = {
      windows = {
         variables = {
            LUA_LIBRARIES = "$(LUA_LIBDIR)/$(LUALIB)"
         }
      }
   },
   variables = {
      BUILD_SHARED_LIBS = "ON",
      CMAKE_INSTALL_PREFIX = "$(PREFIX)",
      LUA_INCLUDE_DIR = "$(LUA_INCDIR)",
      LUA_RAPIDJSON_VERSION = v
   }
}
