# RapidJSON bindings for Lua

[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![Badge][]][Actions]


A json module for LuaJIT 2.0/2.1 and Lua 5.1/5.2/5.3,
based on the very fast [RapidJSON][] C++ library.

See project [homepage][] for more informations,
bug report and feature request.

## Dependencies

* lua development environment
    * `lua-devel` (linux) 
    * or [luavm](https://github.com/xpol/luavm)(windows)
    * or `brew install lua luarocks` 
    * or any equivalent on your system
* `cmake` >= `3.1.0`, cmake 2.8 may work but not well tested.

## Usage

    luarocks install rapidjson

or if you like to use your own version of RapidJSON, use:

    luarocks install rapidjson RAPIDJSON_INCLUDE_DIRS=path/to/rapidjson/include/dir

```Lua
local rapidjson = require('rapidjson')

rapidjson.encode()
rapidjson.decode()

rapidjson.load()
rapidjson.dump()
```

### Usage without luarocks

1. Use `cmake -H. -Bbuild -G<generator-name>` go generate project.

    *If you use a non standard lua install location, add environment variable `LUA_DIR` to the directory contains `include` and `lib` for you lua installtion. eg.*

        LUA_DIR=/usr/local/openresty/luajit cmake -H. -Bbuild -G<generator-name>

2. `cmake --build build --config Release` to build the `rapidjosn.so` or `rapidjosn.dll` library.

3. Then link that library to you project or copy to desired place.

> Tips: use `cmake --help` to see a list of generator-name available.

## Value Type Mappings

Lua Type          | JSON type    | Notes
------------------|--------------|----------------------
`rapidjson.null`  |`null`        |
`true`            |`true`        |
`false`           |`false`       |
string            |string        |
table             |array         |when meta field `__jsontype` is `'array'` or no `__jsontype` meta filed and table length > 0 or table length == 0 and empty_table_as_array option is specified
table             |object        |when not an array, all non string keys and its values are ignored.
number            |number        |

## Test

Clone or download source code, in the project root folder:

    luarocks install luautf8
    luarocks install busted
    luarocks make
    busted

## Performance

To compare speed of rapidjson and other json libraries:

    lua performance/run.lua

The result on my Macbook Pro shows:
 - For decoding, lua-rapidjson is slightly faster than lua-cjson in most cases.
 - For encoding, lua-rapidjson is always faster than lua-cjson, and much faster when encoding numbers.

## API

See [API reference](API.md).

## Release Steps

1. Pass all unit tests.
2. Update version in rapidjson-*.*.*-1.rockspec and update the name of the rockspec file.
3. Tag source code with that version (v*.*.*), and push.
4. `luarocks upload rapidjson-*.*.*-1.rockspec`

## Changelog

### 0.7.0

* Change the `rapidjson.null` type to lightuserdata and fixes the issue when it accessed by different Lua States.

### 0.6.1

* Try support cmake 2.8 with GCC (but still requires c++ compiler support c++11 or at least c++0x).

### 0.6.0

* Add support for decode C buffer + length.
* Export C++ API `pushDecoded`.

### 0.5.2

* Check lua stack when decoding objects and arrays to ensure there is room (Thanks Matthew Johnson).

### 0.5.1

* Remove all c++11 feature requirements except move constructor.

### 0.5.0

* Added Document SchemaDocument SchemaValidator to support JSON pointer and schema.

### 0.4.5

* Checks encoding error for float point numbers.
* RapidJSON compiling turn: use release config and turn SIMD on if supported.

### 0.4.4

* Fixes build and test errors introduced in 0.4.3.

### 0.4.3

* CMakeLists.txt supports command line defined `RAPIDJSON_INCLUDE_DIRS` to specified RapidJSON include directory.
* Keeps only necessary RapidJSON header files and docs make the rock much smaller.

### 0.4.2

* Update RapidJSON to latest HEAD version.

### 0.4.1

* Fixes Windows dll.

### 0.4.0

* Checks circular reference when encoding tables.
* A table is encoded as json array if:
  - have meta field `__jsontype` set to `'array'`.
  - don't have meta filed `__jsontype` and length > 0.
* When table is encoded as json object, **only string keys and its values are encoded**.
* Integers are decoded to lua_Integer if it can be stored in lua_Integer.

### 0.3.0

* Follow integers are encoded as integers.
  - Lua 5.3 integers.
  - Integers stored in double and in between:
    - [INT64_MIN..INT64_MAX] on 64 bit Lua or
    - [INT32_MIN..INT32_MAX] in 32 bit Lua.
* CI scripts updated, thanks @ignacio

### 0.2.0

* Rename module to `rapidjson`.
* Added `option.sort_keys` option to `rapidjson.encode()` and `rapidjson.dump()`, and default value for `sort_keys` is `false`.
* Added `rapidjson._NAME` (`"rapidjson"`) and `rapidjson._VERSION`.
* `rapidjson.object()` and `rapidjson.array()` just set metatable field `__jsontype` to `'object'` and `'array'` if passed table already have a metatable.
* fixes dump return value of `false` rather than `nil`.

### 0.1.0

* Initial release.


[RapidJSON]: https://github.com/miloyip/rapidjson
[homepage]: https://github.com/xpol/lua-rapidjson
[Badge]: https://github.com/xpol/lua-rapidjson/workflows/CI/badge.svg
[Actions]: https://github.com/xpol/lua-rapidjson/actions?workflow=CI