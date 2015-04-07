package = "rapidjson"
version = "0.2.1-1"
source = {
  url = 'git://github.com/xpol/rapidjson',
  tag = 'v0.2.1'
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
  homepage = "https://github.com/xpol/rapidjson",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1"
}

-- cmake -Bbuild -H. -DBUILD_SHARED_LIBS=ON
-- cmake --build build --target install --config Release
build = {
  type = 'cmake',
  variables = {
    LUA_RAPIDJSON_VERSION = version,
    CMAKE_INSTALL_PREFIX = "$(PREFIX)",
    LUA_INCLUDE_DIR = "$(LUA_INCDIR)",
    BUILD_SHARED_LIBS="ON",
  },
  -- Override default build options
  platforms = {
    windows = {
      variables = {
        LUA_LIBRARIES = "$(LUA_LIBDIR)$(LUALIB)", -- windows DLL needs link with importlib.
      }
    }
  }
}
