# JSON for Lua

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

### json.encode(value [, option])

**value**:

When passed a table:

1. Trade as array if table contains only integer keys from 1 to n or a empty table has metatable field `__jsontype` set to `array`.
2. Otherwise the table are trade as object and integer keys are converted to string.

When passed with `true`, `false`, number and `json.null`, simply encode as simple json value.

**option**:

A optional table contains follow field:

* `pretty` boolean: true to make output string to be pretty formated.


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

Encode lua table to json string.

### json.load(filename)

Load json file into lua table.


### json.dump(value, filename [, option])

Dump lua table to json file.

### json.null

The placeholder for json null values.

### json.object()

Create

### json.array()
