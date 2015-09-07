# RapidJSON bindings for Lua

[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![TrivisStatus][]][Trivis] [![AppVeyorStatus][]][AppVeyor]


A very fast json module for LuaJIT 2.0/2.1 and Lua 5.1/5.2/5.3.

Based on the very fast [RapidJSON][] C++ library.



See project [homepage][] for more informations,
bug report and feature request.

## Usage

    luarocks install rapidjson

```Lua
local rapidjson = require('rapidjson')

rapidjson.encode()
rapidjson.decode()

rapidjson.load()
rapidjson.dump()
```

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

### rapidjson.decode()

Decode json to lua table.

#### Synopsis

```Lua
value = rapidjson.decode(jsonstring)
```

#### Arguments

**jsonstring**

A json value string to be decoded.

#### Returns

Return table if json is an object or array.

Return `true`, `false`, number and `rapidjson.null` respectively if json is a simple value.

Return nil plus an error message as a second result when passed string is not valid json string.


#### Errors

- When passed value is not (convertable to) string.


### rapidjson.encode()

Encode lua table to json string.

supports the following types:

* boolean
* function (rapidjson.null only)
* number
* string
* table

The json object keys are sorted by the this function.

#### Synopsis

```Lua
string = rapidjson.encode(value [, option])
```

#### Arguments  

**value**:

When passed a table:

1. Trade as array if:
    - metatable field `__jsontype` set to `array`.
    - table contains only integer keys from 1 to n.
2. Otherwise the table are trade as object and integer keys are converted to string.

When passed with `true`, `false`, number and `rapidjson.null`, simply encode as simple json value.

**option**:

A optional table contains follow field:

* `pretty` boolean: Set `true` to make output string to be pretty formated. Default is false.
* `sort_keys` boolean: Set `true` to make json object keys be sorted. Default is `false`.

#### Returns

Return encoded json string on success.
Return nil on failure, plus an error message as a second result.



#### Errors

* When option passed a value other than table.


#### Examples

```Lua
local rapidjson = require('rapidjson')

rapidjson.encode({})     -- '{}'

rapidjson.encode(rapidjson.object()) --> '{}'
rapidjson.encode(rapidjson.array()) --> '[]'

rapidjson.encode(setmetatable({}, {__jsontype='object'})) --> '{}'
rapidjson.encode(setmetatable({}, {__jsontype='array'})) --> '[]'

rapidjson.encode(true) --> 'true'
rapidjson.encode(rapidjson.null) --> 'null'
rapidjson.encode(123) --> '123.0' or '123' in Lua 5.3.


rapidjson.encode({true, false}) --> '[true, false]'

rapidjson.encode({a=true, b=false}) --> '{"a":true,"b":false]'

```


### rapidjson.load()

Load json file into lua table.

#### Synopsis

```Lua
value = rapidjson.load(filename)
```

#### Arguments

**filename**

Json file to be loaded.

#### Returns

Return table if file contains an object or array.

Return `true`, `false`, number and `rapidjson.null` respectively if file contains a simple value.

Return nil plus an error message as a second result when passed file is not valid json file.


#### Errors

- When passed filename is not (convertable to) string.



### rapidjson.dump()

Dump lua value to json file.

#### Synopsis

```Lua
success, err = rapidjson.dump(value, filename [, option])
```

#### Arguments


**value**

Same as in `rapidjson.encode()`.

**filename**

The file path string where to save dumpped rapidjson.


**option**:

Same as in options in `rapidjson.encode()`.

#### Returns

bool: success

Return true on success.

Return false plus an error message as a second result when:

- Value can't be encoded.
- `filename` can't be opened for write.

#### Error

* When passed filename is not (convertable to) string.
* When passed option is not table, nil or none.


#### Example

```Lua
local rapidjson = require('rapidjson')

rapidjson.dump({rapidjson.null}, 'test.json')
rapidjson.dump({rapidjson.null}, 'test-pretty.json', {pretty=true})

```

### rapidjson.null

The placeholder for null values in rapidjson.

eg.

```Lua
local rapidjson = require('rapidjson')

rapidjson.decode('[null]') --> {rapidjson.null}
rapidjson.encode({rapidjson.null}) --> '[null]'

```

### rapidjson.object()

Create a new empty table that have metatable field `__jsontype` set as `'object'` so that the `encode` and `dump` function will encode it as json object.

When passed an valid table:

* Passed table do not have metatable, just set above metatable for the table.
* Passed table already have metatable, just the the metatable field `__jsontype` to 'object'.

#### Synopsis

```Lua
obj = rapidjson.object([t])
```

#### Arguments

*t*

Optinal table to be set the metatable with meta field `__jsontype` set as `'object'`.

#### Returns

Origin passed in table when passed with a table.
Or new created table.


### rapidjson.array()

Same as rapidjson.array() except the metatable field `__jsontype` is set as `'array'`. And the `encode` and `dump` function will encode it as json array.

### rapidjson.\_NAME

A string that is `"rapidjson"`.

### rapidjson.\_VERSION

The current loaded rapidjson version. `"scm"` when not build with luarocks.

## Changelog

### 0.2.0

* Rename module to `rapidjson`.
* Added `option.sort_keys` option to `rapidjson.encode()` and `rapidjson.dump()`, and default value for `sort_keys` is `false`.
* Added `rapidjson._NAME` (`"rapidjson"`) and `rapidjson._VERSION`.
* `rapidjson.object()` and `rapidjson.array()` just set metatable field `__jsontype` to `'object'` and `'array'` it passed table already have a metatable.
* fixes dump return value of `false` rather than `nil`.

### 0.1.0

* Initial release.


[RapidJSON]: https://github.com/miloyip/rapidjson
[homepage]: https://github.com/xpol/lua-rapidjson
[Trivis]: https://travis-ci.org/xpol/lua-rapidjson "Travis page"
[TrivisStatus]: https://travis-ci.org/xpol/lua-rapidjson.svg
[AppVeyor]: https://ci.appveyor.com/project/xpol/lua-rapidjson/branch/master "AppVeyor page"
[AppVeyorStatus]: https://ci.appveyor.com/api/projects/status/oa3s51dkatevg81o/branch/master?svg=true
