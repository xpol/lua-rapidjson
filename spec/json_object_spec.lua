--luacheck: ignore describe it
describe('json.object()', function()
  local json = require('json')
  it('should create a new empty table if call without args', function()
    local t = json.object()
    assert.are.same({}, t) -- empty
    local tm = getmetatable(t)
    assert.are_not.equal(nil, tm)
    assert.are.equal('object', tm.__jsontype)

    -- called another time, will return a new table
    local u = json.object()
    assert.are_not.equal(t, u)
    assert.are.same({}, t)
    local um = getmetatable(u)
    assert.are.equal(tm, um) -- share one metatable
  end)

  it('should set metatable to passed table', function()
    local oldmt = {}
    local t = {my=true}
    setmetatable(t, oldmt)
    local r = json.object(t)

    assert.are.same(t, r)
    assert.are.equal(oldmt, getmetatable(r)) -- metatable kept
    assert.are.equal('object', oldmt.__jsontype)
  end)
end)
