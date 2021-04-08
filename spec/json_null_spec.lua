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

  it('should works form different Lua State', function()
    local example = {rapidjson.null}

    assert.are.equal("[null]", rapidjson.encode(example))

    local co = coroutine.create(function()
      return rapidjson.encode(example)
    end)
		local ok, json = coroutine.resume(co)
    assert.are.equal(true, ok)
    assert.are.equal("[null]", json)
  end)

end)
