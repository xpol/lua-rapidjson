--luacheck: ignore describe it
describe('rapidjson.schema_validate()', function()
  local rapidjson = require('rapidjson')

  simple_valid_schema = [[
    {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": { "q": { "type": "string" } },
    "required": [ "q" ]
    }
    ]]

  simple_invalid_schema = [[
    {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": { "q": { "type": "string" } },
    "required": [ "q" ]
    ]]

  complex_schema = [[
    {
      "required": ["name", "age", "email", "foo", "bar"],
      "$schema": "http://json-schema.org/draft-04/schema#",
      "id": "DataTypes.User",
      "title": "DataTypes.User",
      "type": "object",
      "definitions": {
        "DataTypes.X": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "id": "",
          "title": "DataTypes.X",
          "enum": ["P", "R"]
        },
        "DataTypes.Q": {
          "required": ["baz"],
          "$schema": "http://json-schema.org/draft-04/schema#",
          "id": "",
          "title": "DataTypes.Q",
          "type": "object",
          "properties": {"baz": {"$ref": "#/definitions/DataTypes.Z"}}
        },
        "DataTypes.Z": {
          "required": ["quux"],
          "$schema": "http://json-schema.org/draft-04/schema#",
          "id": "",
          "title": "DataTypes.Z",
          "type": "object",
          "properties": {"quux": {"$ref": "#/definitions/DataTypes.X"}}
        }
      },
      "properties": {
        "email": {"type": ["string", "null"]},
        "age": {"type": "integer"},
        "foo": {"$ref": "#/definitions/DataTypes.Q"},
        "name": {"type": "string"},
        "bar": {"$ref": "#/definitions/DataTypes.Z"}
      }
    }
    ]]

  complex_document = [[
    {
      "name": "John Doe",
      "age": 23,
      "email": null,
      "foo": {"baz": {"quux": "P"}},
      "bar": {"quux": "R"}
    }
    ]]

  it('should properly validate against a simple schema', function()
    t = rapidjson.schema_validate(simple_valid_schema, '{"q": "blah"}')
    assert.is_table(t)
    assert.are.equal(t['q'], 'blah')

    -- shouldn't validate -- `q` is not a string
    t = rapidjson.schema_validate(simple_valid_schema, '{"q": 3}')
    assert.is_not_table(t)
    assert.is_not_true(t)
  end)

  it('should raise an error when the document is invalid JSON', function()
    assert.has_error(function()
      rapidjson.schema_validate(simple_valid_schema, '{"q":}')
    end)
  end)

  it('should raise an error when the schema is invalid JSON', function()
    assert.has_error(function()
      rapidjson.schema_validate(simple_invalid_schema,'{"q":"blah"}')
    end)
  end)

  it('should properly work on a real-world schema', function()
    t = rapidjson.schema_validate(complex_schema, complex_document)
    assert.is_table(t)
    assert.are.equal(t['name'], 'John Doe')
  end)
end)
