--luacheck: ignore describe it
describe('rapidjson.array()', function()
  local rapidjson = require('rapidjson')
  it('should create a new empty table if call without args', function()
    local t = rapidjson.array()
    assert.are.same({}, t) -- empty
    local tm = getmetatable(t)
    assert.are_not.equal(nil, tm)
    assert.are.equal('array', tm.__jsontype)

    -- called another time, will return a new table
    local u = rapidjson.array()
    assert.are_not.equal(t, u)
    assert.are.same({}, t)
    local um = getmetatable(u)
    assert.are.equal(tm, um) -- share the same metatable
  end)

  it('should set metatable to passed table', function()
    local oldmt = {}
    local t = {my=true}
    setmetatable(t, oldmt)
    local r = rapidjson.array(t)

    assert.are.same(t, r)
    assert.are.equal(oldmt, getmetatable(r)) -- metatable kept
    assert.are.equal('array', oldmt.__jsontype)
  end)
end)
