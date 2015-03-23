--luacheck: ignore describe it
describe('json.encode()', function()
  local json = require('json')
  local function Int(value)
    return _VERSION < 'Lua 5.3' and value..'.0' or value
  end
  it('should encode simple values', function()
    assert.are.equal('"very funny"', json.encode('very funny'))
    assert.are.equal(Int'1234', json.encode(1234))
    assert.are.equal('12.34', json.encode(12.34))
    assert.are.equal('null', json.encode(json.null))
    assert.are.equal('true', json.encode(true))
    assert.are.equal('false', json.encode(false))
  end)

  it('should detect integers', function()
    assert.are.equal(Int'0', json.encode(0))
    assert.are.equal(Int'0', json.encode(-0))
    assert.are.equal(Int'-1', json.encode(-1))
    assert.are.equal(Int'2147483647', json.encode(2147483647)) -- 0x7fffffff, INT_MAX on 32 bit system
    assert.are.equal(Int'-2147483648', json.encode(-2147483648)) -- 0x80000000, INT_MIN on 32 bit system

    if tostring(0x7fffffffffffffff) == '9223372036854775807' then -- check if Lua is compiled with 64 bit integer
      assert.are.equal(Int'9223372036854775807', json.encode(0x7fffffffffffffff))
      assert.are.equal(Int'-9223372036854775808', json.encode(0x8000000000000000))
    end
  end)

  it('should not enocde invalid values', function()
    local r, m = json.encode(function()end)
    assert.are.equal(nil, r)
    assert.are.equal("can't encode to json.", m)

    r, m = json.encode(nil)
    assert.are.equal(nil, r)
    assert.are.equal("can't encode to json.", m)

    r, m = json.encode(io.output())
    assert.are.equal(nil, r)
    assert.are.equal("can't encode to json.", m)
  end)


  it('should encode empty object', function()
    assert.are.equal('{}', json.encode({}))
    assert.are.equal('{}', json.encode(setmetatable({}, {__jsontype='object'})))
    assert.are.equal('{}', json.encode(json.object()))
  end)

  it('should encode empty array', function()
    assert.are.same('[]', json.encode(setmetatable({}, {__jsontype='array'})))
    assert.are.same('[]', json.encode(json.array()))
  end)


  it('should encode simple array', function()
    assert.are.same('['..Int'1'..',2.1'..',"3",true]', json.encode({1, 2.1, '3', true}))
  end)

  it('should encode simple object', function()
    assert.are.same(
      '{"a":'..Int'1'..',"b":2.1,"c":"","d":false}',
      json.encode({a=1, b=2.1, c='', d=false})
    )
  end)

  it('should encode nested objects', function()
    assert.are.same(
      '{"a":[{"b":[1.1,2.2,3.3],"c":{}},{}]}',
      json.encode({a={{b={1.1,2.2,3.3}, c={}}, {}}})
    )
  end)

  it('should parse escaped characters', function()
    assert.are.same(
      '["\\\"","\\\\","/","\\b","\\f","\\n","\\r","\\t","!"]',
      json.encode({[["]],[[\]], [[/]], '\b','\f','\n','\r','\t','!'})
    )
  end)

  it('should encode all number formats', function()
    assert.are.same(
      '['..Int('1000')..','..Int('-1000')..',23.4,-23.4,1990.0,-10000000.0,-0.001,10000000.0,1990.0,1990.0,-0.00199,-1990.0]',
      json.encode({1000, -1000, 23.4, -23.4, 1.99e3, -100E5, -100e-5, 100e5, 1.99E3, 1.99E3, -1.99e-3, -1.99e3}))

    assert.are.equal(
      '[2.3456789012e76]',
      json.encode({2.3456789012e76})
    )
  end)

  it('should support pretty options', function()
    assert.are.same(
[[{
    "a": [
        {
            "b": [
                1.1,
                2.2,
                3.3
            ],
            "c": {}
        },
        {}
    ]
}]],
      json.encode({a={{b={1.1,2.2,3.3}, c={}}, {}}}, {pretty=true})
    )
  end)

  it('should encode utf-8 string', function()
    assert.are.equal(
      [[{"en":"I can eat glass and it doesn't hurt me.",]]..
      [["ja":"私はガラスを食べられます。それは私を傷つけません。",]]..
      [["ko":"나는 유리를 먹을 수 있어요. 그래도 아프지 않아요",]]..
      [["zh-Hans":"我能吞下玻璃而不伤身体。",]]..
      [["zh-Hant":"我能吞下玻璃而不傷身體。"}]],
      json.encode({
        ["en"] = "I can eat glass and it doesn't hurt me.",
        ["zh-Hant"] = "我能吞下玻璃而不傷身體。",
        ["zh-Hans"] = "我能吞下玻璃而不伤身体。",
        ["ja"] = "私はガラスを食べられます。それは私を傷つけません。",
        ["ko"] = "나는 유리를 먹을 수 있어요. 그래도 아프지 않아요"
      })
    )
  end)
end)
