--luacheck: ignore describe it
describe('Json module', function()
  local json = require('json')

  it('should return nil when load string with length < 2', function()
    assert.are.equal(nil, json.load(''))
    assert.are.equal(nil, json.load('1'))
  end)

  it('should return empty table when load empty array', function()
    local a = json.load('[]')
    assert.are.same({}, a)
  end)

  it('should return empty table when load empty object', function()
    local a = json.load('{}')
    assert.are.same({}, a)
  end)

  it('should load simple array', function()
    local a = json.load('[1, 2, "3", true]')
    local e = {1, 2, '3', true}
    assert.are.same(e, a)
  end)

  it('should load simple object', function()
    local a = json.load('{"a":1, "b":2.1, "c":"", "d":false}')
    local e = {a=1, b=2.1, c='', d=false}
    assert.are.same(e, a)
  end)

  it('should handle escaped characters', function()
    local a = json.load([[ ["\"", "\\", "\/", "\b", "\f", "\n", "\r", "\t", "\u0021"] ]])
    local e = {[["]],[[\]], [[/]], '\b','\f','\n','\r','\t','!'}
    assert.are.same(e, a)
  end)

  it('should handle all number formats', function()
    local a = json.load([[ [1000, -1000, 23.4, -23.4, 100e5, 1.99e3, -100E5, -100e-5, 100e+5, 1.99E3, 1.99E+3, -1.99e-3, -1.99e+3] ]])
    local e = {1000, -1000, 23.4, -23.4, 100e5, 1.99e3, -100E5, -100e-5, 100e5, 1.99E3, 1.99E3, -1.99e-3, -1.99e3}
    assert.are.same(e, a)
  end)

  it('should handle all boolean values', function()
    local a = json.load([[ [true, false] ]])
    assert.are.same({true, false}, a)
  end)

  it('should return nil when load numbers', function()
    -- number can convert to string so we can't rise arg error.
    assert.are.equal(nil, json.load(1000))
    assert.are.equal(nil, json.load(100.0))
  end)

  it('should has errors when other types', function()
    assert.has_error(function() json.load(true) end)
    assert.has_error(function() json.load(false) end)
    assert.has_error(function() json.load(function()end) end)
    assert.has_error(function() json.load({}) end)
  end)

  it('should handle nested objects', function()
    local a = json.load([[ {"a":[{"b":[1, 2, 3], "c":{}}]} ]])
    assert.are.same({a={{b={1,2,3}, c={}}}}, a)
  end)

  --TODO: test more bad formated json strings...
end)
