## Summary

* [decode](#decode)
* [encode](#encode)
* [load](#load)
* [dump](#dump)
* [object](#object)
* [array](#array)
* [_NAME](#_name)
* [_VERSION](#_version)
* [Document](#document)
    * [parse](#parse)
    * [get](#get)
* [SchemaDocument](#schemadocument)
* [SchemaValidator](#schemavalidator)
    * [validate](#validate)

## decode

*syntax:* `value, err = rapidjson.decode(jsonstring)`

* **jsonstring**: A JSON value string to be decoded.

Decode JSON to Lua table.

Return table if JSON is an object or array.

Return `true`, `false`, number and `rapidjson.null` respectively if JSON is a simple value.

Return nil plus an error message as a second result when passed string is not a valid JSON.

[Back to TOC]($summary)

## encode()

*syntax:* `str, err = rapidjson.encode(value [, option])`

* **value**: When passed a table:
    * it is encoded as JSON array if:
        - meta field `__jsontype` set to `array`.
        - table contains length > 0.
    * otherwise the table is encoded as JSON object and non string keys and its values are ignored.
    When passed with `true`, `false`, number and `rapidjson.null`, simply encode as simple JSON value.

* **option**: A optional table contains follow field:

    * `pretty` boolean: Set `true` to make output string to be pretty formated. Default is false.
    * `sort_keys` boolean: Set `true` to make JSON object keys be sorted. Default is `false`.
    * `empty_table_as_array` boolean: Set `true` to make empty table encode as JSON array. Default is `false`.

Encodes Lua table to stringified JSON.

Supports the following types:

* boolean
* rapidjson.null (it is actually a function)
* number
* string
* table

The JSON object keys are sorted by the this function.

Returns stringified JSON on success.
Returns nil on failure, plus an error message as a second result.

Here are some examples:

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

[Back to TOC]($summary)

## load()

*syntax:* `value, err = rapidjson.load(filename)`

* **filename**: JSON file to be loaded.

Loads JSON file into Lua table.

Returns table if file contains an object or array.
Returns `true`, `false`, number and `rapidjson.null` respectively if file contains a simple value.

Returns nil plus an error message as a second result when passed file is not valid JSON file.

[Back to TOC]($summary)

## dump()

*syntax:* `ok, err = rapidjson.dump(value, filename [, option])`

* **value**: same as in `rapidjson.encode()`.
* **filename**: The file path string where to save stringified rapidjson.
* **option**: Same as in options in `rapidjson.encode()`.

Dumps Lua value to JSON file.

Return true on success.

Return false plus an error message as a second result when:
- Value can't be encoded.
- `filename` can't be opened for write.

```Lua
local rapidjson = require('rapidjson')

rapidjson.dump({rapidjson.null}, 'test.json')
rapidjson.dump({rapidjson.null}, 'test-pretty.json', {pretty=true})
```

[Back to TOC]($summary)

## null

The placeholder for null values in rapidjson.

For example:

```Lua
local rapidjson = require('rapidjson')

rapidjson.decode('[null]') --> {rapidjson.null}
rapidjson.encode({rapidjson.null}) --> '[null]'

```

[Back to TOC]($summary)

## object()

*syntax:* `obj = rapidjson.object([t])`

* **t**: Optional table to be set the metatable with meta field `__jsontype` set as `'object'`.

Create a new empty table that have metatable field `__jsontype` set as `'object'` so that the `encode` and `dump` function will encode it as JSON object.

When passed an valid table:

* Passed table do not have metatable, just set above metatable for the table.
* Passed table already have metatable, set the metatable field `__jsontype` to 'object'.

If a table is passed in, return this table, otherwise a new table will be created.

## array()

Same as `rapidjson.object()` except the metatable field `__jsontype` is set as `'array'`. And the `encode` and `dump` function will encode it as JSON array.


## \_NAME

A string that is `"rapidjson"`.

## \_VERSION

The current loaded rapidjson version. `"scm"` when not build with luarocks.

## Document()

*syntax:* `doc = rapidjson.Document([t|s])`

* **t**: Optional table to be create a rapidjson Document from.
* **s**: Optional a string contains a JSON document, then when document created the string is parsed into the document.

Creates a rapidjson Document object. Optionally create from a Lua table or string of JSON document.

## document:parse()

*syntax:* `ok, message = document:parse(s)`

* **s**: A string contains a JSON document.

Parses JSON document contained in string s.

Returns `true` on success. Otherwise `false` and an additional error message is returned.

```lua
local rapidjson = require('rapidjson')
local doc = rapidjson.Document()
local ok, message = doc:parse('{"a":["appke", "air"]}')
if not ok then
  print(message)
end
```

## document:get()

*syntax:* `value = document:get(pointer[, default])`

* **pointer**: A string contains JSON pointer.

* **default**: The default value to return if the document does not contains value specified by the pointer.

Get document member by [JSON Pointer](http://rapidjson.org/md_doc_pointer.html).

It document have elements specified by pointer, the element value is returned as a Lua value.
Otherwise, `default` value is returned; if `default` is not specified, `nil` is returned.

## document:set()

*syntax:* `document:set(pointer, value)`

* **pointer**: A string contains JSON pointer.
* **value**: The value to set as new value for document element specified by pointer.

Set document member by [JSON Pointer](http://rapidjson.org/md_doc_pointer.html) with specified value.

```lua
local doc = rapidjson.Document()
doc:set('/a', {'apple', 'air'})
```

## SchemaDocument()

*syntax:* `sd = rapidjson.SchemaDocument(doc|t|s)`

* **doc**: The the JSON schema stored in rapidjson.Document object.

* **t**: The Lua table representation of a JSON schema.

* **s**: The string contains a JSON schema.

Creates a SchemaDocument from Document or a Lua table or a string contains a JSON schema.

Returns the new SchemaDocument object.

```lua
local d = rapidjson.Document('{"type": ["string", "number"]}')
local sd = rapidjson.SchemaDocument(d)
```

```lua
local sd = rapidjson.SchemaDocument({type= {"string", "number"}})
```

```lua
local sd = rapidjson.SchemaDocument('{"type": ["string", "number"]}')
```

## SchemaValidator()

*syntax:* `validator = apidjson.SchemaValidator(sd)`

* **sd**: The SchemaDocument to create the validator. SchemaDocument can be shared by schema validators.

Creates a SchemaValidator from a SchemaDocument.

Returns the new created validator object.

```lua
local sd = rapidjson.SchemaDocument('{"type": ["string", "number"]}')
local validator = rapidjson.SchemaValidator(sd)

local d = rapidjson.Document('.....')

local ok, message = validator:validate(d)
```

## SchemaValidator:validate()

*syntax:* `ok, message = validator:validate(d)`

* **d**: The document to be validated against the schema stored inside the validator.

Validates a JSON document.

Returns `true` if the document is valid. Otherwise returns `false` and a extra error message.
