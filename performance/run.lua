



local function time(f, times)
  collectgarbage()
  local gettime = os.clock

  local ok, socket = pcall(require, 'socket')
  if ok then
    gettime = socket.gettime
  end

  local start = gettime()
  times = times or 1000

  for _=0,times do f() end

  local stop = gettime()

  return stop - start
end


local function readfile(file)
  local f = io.open(file)
  if not f then return nil end
  local d = f:read('*a')
  f:close()
  return d
end


local function profile(jsonfile, times)
  print(jsonfile..': (x'..times..')')
  print('', 'module', '  decoding', '  encoding')
  local d = readfile(jsonfile)

  local json = require('json')
  local cjson = require('cjson')
  local dkjson = require('dkjson')

  local modules = {
    {'dkjson', dkjson.decode, dkjson.encode},
    {'cjson', cjson.decode, cjson.encode},
    {'json', json.decode, json.encode},
  }

  for _, m in ipairs(modules) do
    local name, dec, enc = m[1], m[2], m[3]
    local td = time(function() dec(d) end, times)
    local t = dec(d)
    local te = time(function() enc(t) end, times)
    print(string.format('\t%6s\t% 13.10f\t% 13.10f', name, td, te))
  end
end

local function main()
  profile('performance/nulls.json', 1000)
  profile('performance/booleans.json', 1000)
  profile('performance/guids.json', 1000)
  profile('performance/paragraphs.json', 1000)
  profile('performance/floats.json', 1000)
  profile('performance/integers.json', 1000)
  profile('performance/mixed.json', 1000)
end

local r, m = pcall(main)

if not r then
  print(m)
end

return 0
