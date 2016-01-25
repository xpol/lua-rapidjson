--luacheck: ignore describe it
local utf8 = require "dromozoa.utf8.pure" -- luarocks install utf8
describe('rapidjson.load()', function()
  local rapidjson = require('rapidjson')
  describe('report error', function()
    it('when load file not exist', function()
      assert.are.has_error(function()
        rapidjson.load('not-exist-file.json')
      end)
    end)
  end)
  describe('should return nil', function()
    it('when load bad json file', function()
      local r, m

      r, m = rapidjson.load('spec/empty-file.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail10.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail11.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail12.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail13.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail14.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail15.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail16.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail17.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail19.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail2.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail20.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail21.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail22.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail23.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail24.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail25.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail26.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail27.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail28.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail29.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail3.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail30.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail31.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail32.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail33.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail4.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail5.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail6.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail7.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail8.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))

      r, m = rapidjson.load('rapidjson/bin/jsonchecker/fail9.json')
      assert.are.equal(nil, r)
      assert.are.equal('string', type(m))
    end)

    describe('should return valid table', function()
      it('when load valid json file', function()
        local a, e
        a = rapidjson.load('rapidjson/bin/jsonchecker/pass1.json')
        e = {
            "JSON Test Pattern pass1",
            {["object with 1 member"]={"array with 1 element"}},
            {},
            {},
            -42,
            true,
            false,
            rapidjson.null,
            {
                ["integer"] = 1234567890,
                ["real"] = -9876.543210,
                ["e"] = 0.123456789e-12,
                ["E"] = 1.234567890E+34,
                [""] =  23456789012E66,
                ["zero"] = 0,
                ["one"] = 1,
                ["space"] = " ",
                ["quote"] = "\"",
                ["backslash"] = "\\",
                ["controls"] = "\b\f\n\r\t",
                ["slash"] = "/ & /",
                ["alpha"] = "abcdefghijklmnopqrstuvwyz",
                ["ALPHA"] = "ABCDEFGHIJKLMNOPQRSTUVWYZ",
                ["digit"] = "0123456789",
                ["0123456789"] = "digit",
                ["special"] = "`1~!@#$%^&*()_+-={':[,]}|;.</>?",
                ["hex"] = utf8.char(0x123,0x4567,0x89AB,0xCDEF,0xabcd,0xef4A),
                ["true"] = true,
                ["false"] = false,
                ["null"] = rapidjson.null,
                ["array"] = {},
                ["object"] = {},
                ["address"] = "50 St. James Street",
                ["url"] = "http://www.JSON.org/",
                ["comment"] = "// /* <!-- --",
                ["# -- --> */"] = " ",
                [" s p a c e d "] = {1,2,3,4,5,6,7},["compact"] ={1,2,3,4,5,6,7},
                ["jsontext"] = "{\"object with 1 member\":[\"array with 1 element\"]}",
                ["quotes"] = "&#34; "..utf8.char(0x0022).." %22 0x22 034 &#x22;",
                ["/\\\""..utf8.char(0xCAFE,0xBABE,0xAB98,0xFCDE,0xbcda,0xef4A).."\b\f\n\r\t`1~!@#$%^&*()_+-=[]{}|;:',./<>?"]
                  = "A key can be any string"
            },
            0.5 ,98.6
        ,
        99.44
        ,
        1066,
        1e1,
        0.1e1,
        1e-1,
        1e00,2e00,2e-00
        ,"rosebud"}

        assert.are.same(string.format("%.16g", e[9]['E']), string.format("%.16g", a[9]['E']))
        assert.are.same(string.format("%.16g", e[9]['']), string.format("%.16g", a[9]['']))
        a[9]['E'], a[9][''], e[9]['E'], e[9][''] = nil, nil, nil, nil
        assert.are.same(e, a)

        a = rapidjson.load('rapidjson/bin/jsonchecker/pass2.json')
        assert.are.same({{{{{{{{{{{{{{{{{{{"Not too deep"}}}}}}}}}}}}}}}}}}}, a)

        a = rapidjson.load('rapidjson/bin/jsonchecker/pass3.json')
        assert.are.same({
            ["JSON Test Pattern pass3"] = {
                ["The outermost value"] = "must be an object or array.",
                ["In this test"] = "It is an object."
            }
        }, a)

        a = rapidjson.load('spec/empty-array.json')
        assert.are.same({}, a)

        a = rapidjson.load('spec/empty-object.json')
        assert.are.same({}, a)
      end)

      -- Non utf8 not supported yet.
      it('when input json file is not utf-8', function()
        local e = {
        	["en"] = "I can eat glass and it doesn't hurt me.",
        	["zh-Hant"] = "我能吞下玻璃而不傷身體。",
        	["zh-Hans"] = "我能吞下玻璃而不伤身体。",
        	["ja"] = "私はガラスを食べられます。それは私を傷つけません。",
        	["ko"] = "나는 유리를 먹을 수 있어요. 그래도 아프지 않아요"
        }
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf16be.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf16bebom.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf16le.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf16lebom.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf32be.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf32bebom.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf32le.json'))
        --assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf32lebom.json'))
        assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf8.json'))
        assert.are.same(e, rapidjson.load('rapidjson/bin/encodings/utf8bom.json'))
      end)
    end)
  end)
end)
