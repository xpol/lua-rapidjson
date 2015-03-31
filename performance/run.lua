local json = require('json')
local cjson = require('cjson')
local socket = require('socket')

local function time(title, f, times)
  collectgarbage()

  local start = socket.gettime()
  times = times or 1000

  for _=0,times do f() end

  local stop = socket.gettime()

  print( '',title, stop - start )
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
  local d = readfile(jsonfile)
  time("json.decode()", function() json.decode(d) end, times)
  time("cjson.decode()", function() cjson.decode(d) end, times)
  local t = json.decode(d)
  time("json.encode()", function() json.encode(t) end, times)
  t = cjson.decode(d)
  time("cjson.encode()", function() cjson.encode(t) end, times)
end

profile('rapidjson/bin/data/sample.json', 1000)
profile('rapidjson/bin/data/webapp.json', 100000)
return 0
