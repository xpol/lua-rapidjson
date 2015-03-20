--luacheck: ignore describe it
describe('json.load()', function()
  local json = require('json')
  describe('should return nil', function()
    it('when load string with length < 2', function()
      assert.are.equal(nil, json.load('1'))
    end)

    it('when load numbers', function()
      -- number can convert to string so we can't rise arg error.
      assert.are.equal(nil, (json.load(1)))
      assert.are.equal(nil, json.load(1000))
      assert.are.equal(nil, json.load(100.0))
    end)

    it('when parse invalid json data', function()
      local r, m

      r, m = json.load('')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "The document is empty.", 1, true))

      r, m = json.load('{}10')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "The document root must not follow by other values.", 1, true))

      r, m = json.load('{"a":b}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Invalid value.", 1, true))

      r, m = json.load('{12}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Missing a name for object member.", 1, true))

      r, m = json.load('{"a",}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Missing a colon after a name of object member.", 1, true))

      r, m = json.load('{"a":[] "b":[]}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Missing a comma or '}' after an object member.", 1, true))

      r, m = json.load('[{}{}]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Missing a comma or ']' after an array element.", 1, true))

      r, m = json.load('["\\uke"]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Incorrect hex digit after \\u escape in string.", 1, true))

      r, m = json.load('["\\p"]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Invalid escape character in string.", 1, true))

      r, m = json.load('["a]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Missing a closing quotation mark in string.", 1, true))

      r, m = json.load('[999999999999999999e9999999999999999999]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Number too big to be stored in double.", 1, true))

      r, m = json.load('[0.,]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Miss fraction part in number.", 1, true))

      r, m = json.load('[1.2e,]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      assert.are_not.equal(nil, string.find(m, "Miss exponent in number.", 1, true))
      --"The surrogate pair in string is invalid. ()", ''
      --"Invalid encoding in string. ()",
    end)
  end)

  describe('should raise error', function()
    it('when arg type are neither string nor number', function()
      -- bad argument #1 to 'load' (string expected, got ...)
      assert.has_error(function() json.load(true) end)
      assert.has_error(function() json.load(false) end)
      assert.has_error(function() json.load(function()end) end)
      assert.has_error(function() json.load({}) end)
      assert.has_error(function() json.load(io.input()) end)
    end)
  end)

  describe('sould return empty table', function()
    it('when load empty array', function()
      local a = json.load('[]')
      assert.are.same({}, a)
    end)

    it('when load empty object', function()
      local a = json.load('{}')
      assert.are.same({}, a)
    end)
  end)

  describe('should return valid table', function()
    it('when load simple array', function()
      local a = json.load('[1, 2, "3", true]')
      local e = {1, 2, '3', true}
      assert.are.same(e, a)
    end)

    it('when load simple object', function()
      local a = json.load('{"a":1, "b":2.1, "c":"", "d":false}')
      local e = {a=1, b=2.1, c='', d=false}
      assert.are.same(e, a)
    end)

    it('when load nested objects', function()
      local a = json.load([[ {"a":[{"b":[1, 2, 3], "c":{}}, {}]} ]])
      assert.are.same({a={{b={1,2,3}, c={}}, {}}}, a)
    end)
  end)

  describe('valid json data formts', function()
    it('should parse escaped characters', function()
      local a = json.load([[ ["\"", "\\", "\/", "\b", "\f", "\n", "\r", "\t", "\u0021"] ]])
      local e = {[["]],[[\]], [[/]], '\b','\f','\n','\r','\t','!'}
      assert.are.same(e, a)
    end)

    it('should parse all number formats', function()
      local a = json.load([[ [1000, -1000, 23.4, -23.4, 100e5, 1.99e3, -100E5, -100e-5, 100e+5, 1.99E3, 1.99E+3, -1.99e-3, -1.99e+3] ]])
      local e = {1000, -1000, 23.4, -23.4, 100e5, 1.99e3, -100E5, -100e-5, 100e5, 1.99E3, 1.99E3, -1.99e-3, -1.99e3}
      assert.are.same(e, a)
    end)

    it('should parse all boolean values', function()
      local a = json.load([[ [true, false] ]])
      assert.are.same({true, false}, a)
    end)

    it('shuld parse null', function()
      local a = json.load([[ [null] ]])
      local e = {json.null}
      assert.are.same(e, a)
    end)
  end)
end)
