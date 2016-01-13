--luacheck: ignore describe it
describe('rapidjson.decode()', function()
  local rapidjson = require('rapidjson')
  describe('should return value', function()
    it('when decode values without array or object', function()
      assert.are.equal('very funny', rapidjson.decode('"very funny"'))
      assert.are.equal(1234, rapidjson.decode('1234'))
      assert.are.equal(12.34, rapidjson.decode('12.34'))
      assert.are.equal(rapidjson.null, rapidjson.decode('null'))
      assert.are.equal(true, rapidjson.decode('true'))
      assert.are.equal(false, rapidjson.decode('false'))
      assert.are.equal(1E20, rapidjson.decode('100000000000000000000'))
      if tostring(0x7fffffffffffffff) == '9223372036854775807' then -- check if Lua is compiled with 64 bit integer
        assert.are.equal(9223372036854775807, rapidjson.decode('9223372036854775807'))
      end
    end)

    it('when parse invalid json data', function()
      local r, m, idx

      r, m = rapidjson.decode('')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "The document is empty.", 1, true)
      assert.are_not.equal(nil, idx)



      r, m = rapidjson.decode('{}10')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "The document root must not follow by other values.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('{"a":b}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Invalid value.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('{12}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Missing a name for object member.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('{"a",}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Missing a colon after a name of object member.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('{"a":[] "b":[]}')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Missing a comma or '}' after an object member.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('[{}{}]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Missing a comma or ']' after an array element.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('["\\uke"]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Incorrect hex digit after \\u escape in string.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('["\\p"]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Invalid escape character in string.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('["a]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Missing a closing quotation mark in string.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('[999999999999999999e9999999999999999999]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Number too big to be stored in double.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('[0.,]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Miss fraction part in number.", 1, true)
      assert.are_not.equal(nil, idx)

      r, m = rapidjson.decode('[1.2e,]')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
      idx = string.find(m, "Miss exponent in number.", 1, true)
      assert.are_not.equal(nil, idx)
      --"The surrogate pair in string is invalid. ()", ''
      --"Invalid encoding in string. ()",
    end)
  end)

  describe('should raise error', function()
    it('when arg type are neither string nor number', function()
      assert.has_error(function() rapidjson.decode(true) end)
      assert.has_error(function() rapidjson.decode(false) end)
      assert.has_error(function() rapidjson.decode(function()end) end)
      assert.has_error(function() rapidjson.decode({}) end)
      assert.has_error(function() rapidjson.decode(io.input()) end)
    end)
  end)

  describe('sould return empty table', function()
    it('when decode empty array', function()
      local a = rapidjson.decode('[]')
      assert.are.same({}, a)
    end)

    it('when decode empty object', function()
      local a = rapidjson.decode('{}')
      assert.are.same({}, a)
    end)
  end)

  describe('should return valid table', function()
    it('when decode simple array', function()
      local a = rapidjson.decode('[1, 2, "3", true]')
      local e = {1, 2, '3', true}
      assert.are.same(e, a)
    end)

    it('when decode simple object', function()
      local a = rapidjson.decode('{"a":1, "b":2.1, "c":"", "d":false}')
      local e = {a=1, b=2.1, c='', d=false}
      assert.are.same(e, a)
    end)

    it('when decode nested objects', function()
      local a = rapidjson.decode([[ {"a":[{"b":[1, 2, 3], "c":{}}, {}]} ]])
      assert.are.same({a={{b={1,2,3}, c={}}, {}}}, a)
    end)
  end)

  describe('valid json data formts', function()
    it('should parse escaped characters', function()
      local a = rapidjson.decode([[ ["\"", "\\", "\/", "\b", "\f", "\n", "\r", "\t", "\u0021"] ]])
      local e = {[["]],[[\]], [[/]], '\b','\f','\n','\r','\t','!'}
      assert.are.same(e, a)
    end)

    it('should parse all number formats', function()
      local a = rapidjson.decode([[ [1000, -1000, 23.4, -23.4, 100e5, 1.99e3, -100E5, -100e-5, 100e+5, 1.99E3, 1.99E+3, -1.99e-3, -1.99e+3] ]])
      local e = {1000, -1000, 23.4, -23.4, 100e5, 1.99e3, -100E5, -100e-5, 100e5, 1.99E3, 1.99E3, -1.99e-3, -1.99e3}
      assert.are.same(e, a)

      a = rapidjson.decode([[{"x":  23456789012E66}]])
      e = {x=  23456789012E66}
      assert.are.equal(tostring(e.x), tostring(a.x))

    end)


    it('shuld parse null', function()
      local a = rapidjson.decode([[ [null] ]])
      local e = {rapidjson.null}
      assert.are.same(e, a)
    end)
  end)
end)
