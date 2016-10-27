#ifndef __LUA_RAPIDJSION_LUACOMPAT_H__
#define __LUA_RAPIDJSION_LUACOMPAT_H__

#include <cmath>
#include <lua.hpp>

namespace luax {
	inline void setfuncs(lua_State* L, const luaL_Reg* funcs) {
#if LUA_VERSION_NUM >= 502 // LUA 5.2 or above
		luaL_setfuncs(L, funcs, 0);
#else
		luaL_register(L, NULL, funcs);
#endif
	}

	inline size_t rawlen(lua_State* L, int idx) {
#if LUA_VERSION_NUM >= 502
		return lua_rawlen(L, idx);
#else
		return lua_objlen(L, idx);
#endif
	}

	inline bool isinteger(lua_State* L, int idx, int64_t* out = NULL)
	{
#if LUA_VERSION_NUM >= 503
		if (lua_isinteger(L, idx)) // but it maybe not detect all integers.
		{
			if (out)
				*out = lua_tointeger(L, idx);
			return true;
		}
#endif
		double intpart;
		if (std::modf(lua_tonumber(L, idx), &intpart) == 0.0)
		{
			if (std::numeric_limits<lua_Integer>::min() <= intpart
				&& intpart <= std::numeric_limits<lua_Integer>::max())
			{
				if (out)
					*out = static_cast<int64_t>(intpart);
				return true;
			}
		}
		return false;
	}


}





#endif // __LUA_RAPIDJSION_LUACOMPAT_H__
