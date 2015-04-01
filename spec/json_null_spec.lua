--luacheck: ignore describe it
describe('rapidjson.null', function()
  local rapidjson = require('rapidjson')
  it('should encode as null', function()
    assert.are.equal('null', rapidjson.encode(rapidjson.null))
    assert.are.equal('[null]', rapidjson.encode({rapidjson.null}))
    assert.are.equal('{"a":null}', rapidjson.encode({a=rapidjson.null}))
  end)

  it('should be same as all decoded null', function()
      assert.are.equal(rapidjson.null, rapidjson.decode('null'))

      assert.are.same({rapidjson.null}, rapidjson.decode('[null]'))
      assert.are.equal(rapidjson.null, rapidjson.decode('[null]')[1])

      assert.are.same({a=rapidjson.null}, rapidjson.decode('{"a":null}'))
      assert.are.equal(rapidjson.null, rapidjson.decode('{"a":null}').a)
  end)
end)
