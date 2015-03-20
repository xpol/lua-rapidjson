extern "C" {
#include <lua.h>
#include <lauxlib.h>
}
#include <rapidjson/rapidjson.h>


static int json_load(lua_State* L)
{
    return 0;
}


static int json_dump(lua_State* L)
{
    return 0;
}

static const luaL_Reg methods[] = {
  {"load", json_load},
  {"dump", json_dump},
  {NULL, NULL}
};




extern "C" {

LUALIB_API int luaopen_json(lua_State* L)
{
    lua_newtable(L);

#if LUA_VERSION_NUM >= 502 // LUA 5.2 or above
      luaL_setfuncs(L, methods, 0);
#else
      luaL_register(L, NULL, methods);
#endif

    return 1;
}

}
