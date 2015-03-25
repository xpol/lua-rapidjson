--luacheck: ignore describe it
describe('json.null', function()
  local json = require('json')
  it('should encode as null', function()
    assert.are.equal('null', json.encode(json.null))
    assert.are.equal('[null]', json.encode({json.null}))
    assert.are.equal('{"a":null}', json.encode({a=json.null}))
  end)

  it('should be same as all decoded null', function()
      assert.are.equal(json.null, json.decode('null'))

      assert.are.same({json.null}, json.decode('[null]'))
      assert.are.equal(json.null, json.decode('[null]')[1])

      assert.are.same({a=json.null}, json.decode('{"a":null}'))
      assert.are.equal(json.null, json.decode('{"a":null}').a)
  end)
end)
