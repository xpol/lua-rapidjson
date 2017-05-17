# RapidJSON bindings for Lua

[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![TrivisStatus][]][Trivis] [![AppVeyorStatus][]][AppVeyor]


A json module for LuaJIT 2.0/2.1 and Lua 5.1/5.2/5.3,
based on the very fast [RapidJSON][] C++ library.

See project [homepage][] for more informations,
bug report and feature request.

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

    luarocks install dromozoa-utf8
    luarocks install busted
    luarocks make
    busted

## Performance

To compare speed of rapidjson and other json libraries:

    lua performance/run.lua


## API

See [API reference](API.md).

## Release Steps

1. Pass all unit tests.
2. Update version in rapidjson-*.*.*-1.rockspec and update the name of the rockspec file.
3. Tag source code with that version (v*.*.*), and push.
4. `luarocks upload rapidjson-*.*.*-1.rockspec`

## Changelog

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
[Trivis]: https://travis-ci.org/xpol/lua-rapidjson "Travis page"
[TrivisStatus]: https://travis-ci.org/xpol/lua-rapidjson.svg
[AppVeyor]: https://ci.appveyor.com/project/xpol/lua-rapidjson/branch/master "AppVeyor page"
[AppVeyorStatus]: https://ci.appveyor.com/api/projects/status/oa3s51dkatevg81o/branch/master?svg=true
