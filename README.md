# JSON for Lua

[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![BuildStatus](https://travis-ci.org/xpol/json.png)][1]
[1]:https://travis-ci.org/xpol/json

A very fast json module for LuaJIT and Lua 5.1/5.2.

Based on the very fast json library RapidJSON.

See project [homepage](https://github.com/xpol/json) for more informations,
bug report and feature request.

## Install

    luarocks install json

## API

### json.decode(jsonstring)

Decode json to lua table.

#### Synopsis

```Lua
value = json.encode(jsonstring)
```

#### Arguments

**jsonstring**

A json value string to be decoded.

#### Returns

Return table if json is an object or array.

Return `true`, `false`, number and `json.null` respectively if json is a simple value.

Return nil plus an error message as a second result when passed string is not valid json string.


#### Errors

- When passed value is not (convertable to) string.


### json.encode(value [, option])

Encode lua table to json string.

#### Synopsis

```Lua
string = json.encode(value [, option])
```

#### Arguments  

**value**:

When passed a table:

1. Trade as array if:
    - metatable field `__jsontype` set to `array`.
    - table contains only integer keys from 1 to n.
2. Otherwise the table are trade as object and integer keys are converted to string.

When passed with `true`, `false`, number and `json.null`, simply encode as simple json value.

**option**:

A optional table contains follow field:

* `pretty` boolean: true to make output string to be pretty formated.

#### Returns

Return encoded json string on success.
Return nil on failure, plus an error message as a second result.



#### Errors

* When option passed a value other than table.


#### Examples

```Lua
local json = require('json')

json.encode({})     -- '{}'

json.encode(json.object()) --> '{}'
json.encode(json.array()) --> '[]'

json.encode(setmetatable({}, {__jsontype='object'})) --> '{}'
json.encode(setmetatable({}, {__jsontype='array'})) --> '[]'

json.encode(true) --> 'true'
json.encode(json.null) --> 'null'
json.encode(123) --> '123.0' or '123' in Lua 5.3.


json.encode({true, false}) --> '[true, false]'

json.encode({a=ture, b=false}) --> '{"a":true,"b":false]'

```


### json.load(filename)

Load json file into lua table.

#### Synopsis

```Lua
value = json.load(filename)
```

#### Arguments

**filename**

Json file to be loaded.

#### Returns

Return table if file contains an object or array.

Return `true`, `false`, number and `json.null` respectively if file contains a simple value.

Return nil plus an error message as a second result when passed file is not valid json file.


#### Errors

- When passed filename is not (convertable to) string.



### json.dump(value, filename [, option])

Dump lua value to json file.

#### Synopsis

```Lua
success, err = json.dump(value, filename [, option])
```

#### Arguments


**value**

Same as in `json.encode()`.

**filename**

The file path string where to save dumpped json.


**option**:

A optional table contains follow field:

* `pretty` boolean: true to make output string to be pretty formated.

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
local json = require('json')

json.dump({json.null}, 'test.json')
json.dump({json.null}, 'test-pretty.json', {pretty=true})

```

### json.null

The placeholder for null values in json.

eg.

```Lua
local json = require('json')

json.decode('[null]') --> {json.null}
json.encode({json.null}) --> '[null]'

```

### json.object()

Create a new empty table that have metatable field `__jsontype` set as `'object'` so that the `encode` and `dump` function will encode it as json object.

When passed an valid table:

* Passed table do not have metatable, just set above metatable for the table.
* Passed table already have metatable, just the the metatable field `__jsontype` to 'object'.

#### Synopsis

```Lua
obj = json.object([t])
```

#### Arguments

*t*

Optinal table to be set the metatable with meta field `__jsontype` set as `'object'`.

#### Returns

Origin passed in table when passed with a table.
Or new created table.


### json.array()

Same as json.array() except the metatable field `__jsontype` is set as `'array'`. And the `encode` and `dump` function will encode it as json array.


## Changelog

### 0.2.0[WIP]

* `json.object()` and `json.array()` just set metatable field `__jsontype` to `'object'` and `'array'` it passed table already have a metatable.
* fixes dump return value of `false` rather than `nil`.

### 0.1.0

* Initial release.
