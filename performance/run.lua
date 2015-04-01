local json = require('json')
local cjson = require('cjson')
local dkjson = require('dkjson')

local socket = require('socket')

local function time(f, times)
  collectgarbage()

  local start = socket.gettime()
  times = times or 1000

  for _=0,times do f() end

  local stop = socket.gettime()

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

  local modules = {
    dkjson = {dkjson.decode, dkjson.encode},
    json = {json.decode, json.encode},
    cjson = {cjson.decode, cjson.encode},
  }

  for name, functions in pairs(modules) do
    local dec, enc = unpack(functions)
    local td = time(function() dec(d) end, times)
    local t = dec(d)
    local te = time(function() enc(t) end, times)
    --print('', name, td, te)
    print(string.format('\t%6s\t% 13.10f\t% 13.10f', name, td, te))
  end
end

local function main()
  profile('rapidjson/bin/data/menu.json', 100000)
  profile('rapidjson/bin/data/webapp.json', 50000)
  profile('rapidjson/bin/data/sample.json', 1000)
end

local r, m = pcall(main)

if not r then
  print(m)
end

return 0
