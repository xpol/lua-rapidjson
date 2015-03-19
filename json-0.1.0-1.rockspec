package = "json"
version = "0.1.0-1"
source = {
  url = 'git://github.com/xpol/json',
  tag = 'v0.1.0',
}

description = {
  summary = "Very fast json module based on RapidJSON",
  detailed = [[
        A very fast json module for luajit and lua 5.1/5.2.

        Based on the very fast json library RapidJSON.

        Provide `json.load()` to convert json to lua table.
        And `json.dump()` to dump lua table to json string.
  ]],
  homepage = "https://github.com/xpol/json",
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
    CMAKE_INSTALL_PREFIX = "$(PREFIX)",
    LUA_LIBDIR = "$(LUA_LIBDIR)",
    LUA_INCDIR = "$(LUA_INCDIR)",
    BUILD_SHARED_LIBS="ON",
  }
}
