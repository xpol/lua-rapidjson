#include <cstdio>
#include <vector>
#include <fstream>

#include <lua.hpp>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <rapidjson/istreamwrapper.h>
#include <rapidjson/pointer.h>

#include "Userdata.hpp"
#include "values.hpp"


using namespace  rapidjson;

const char* const Userdata<Value>::Metatable = "rapidjson.Value";

Value checkValue(lua_State * L, int idx)
{
	size_t len;
	const char* s;
	switch (lua_type(L, 1)) {
		case LUA_TNONE:
		case LUA_TNIL:
			return Value();
		case LUA_TBOOLEAN:
			return Value(lua_toboolean(L, 1) != 0);
		case LUA_TNUMBER:
			return Value(lua_tonumber(L, 1));
		case LUA_TSTRING:
			s = lua_tolstring(L, 1, &len);
			return Value(s, static_cast<SizeType>(len));
		case LUA_TTABLE:

		case LUA_TUSERDATA:
		case LUA_TLIGHTUSERDATA: // Fall-through
		case LUA_TFUNCTION:// Fall-through
		case LUA_TTHREAD:// Fall-through
		default:
			luaL_error(L, "cannot create Value from %s.", luaL_typename(L, 1));
			return Value(); // make compiler happy.
	}
}

const char* const Userdata<Document>::Metatable = "rapidjson.Document";

template<>
Document* Userdata<Document>::construct(lua_State * L)
{
	return new Document();
}


static int pushParseResult(lua_State* L, Document* doc) {
	ParseErrorCode err = doc->GetParseError();
	if (err != kParseErrorNone) {
		lua_pushnil(L);
		lua_pushfstring(L, "%s (at Offset %d)", GetParseError_En(err), doc->GetErrorOffset());
		return 2;
	}

	lua_pushboolean(L, 1);
	return 1;
}

static int Document_parse(lua_State* L) {
	Document* doc = Userdata<Document>::get(L, 1);

	size_t l = 0;
	const char* s = luaL_checklstring(L, 2, &l);
	doc->Parse(s, l);

	return pushParseResult(L, doc);
}

static int Document_parseFile(lua_State* L) {
	Document* doc = Userdata<Document>::get(L, 1);

	const char* s = luaL_checkstring(L, 2);
	std::ifstream ifs(s);
	IStreamWrapper isw(ifs);

	doc->ParseStream(isw);

	return pushParseResult(L, doc);;
}


/**
 * doc:get('path'[, default])
 */
static int Document_get(lua_State* L) {
	Document* doc = Userdata<Document>::check(L, 1);
	Pointer ptr(luaL_checkstring(L, 2));
	Value* v = ptr.Get(*doc);

	if (!v) {
		if (lua_gettop(L) >= 3) {
			lua_pushvalue(L, 3);
		}
		else {
			lua_pushnil(L);
		}
	}
	else {
		values::push(L, *v);
	}
	return 1;
}

static int Document_set(lua_State* L) {
	Document* doc = Userdata<Document>::check(L, 1);
	Pointer ptr(luaL_checkstring(L, 2));
	Value v(values::toValue(L, 3, doc->GetAllocator()));

	ptr.Set(*doc, v, doc->GetAllocator());

	return 0;
}


static const luaL_Reg reg[] = {
	{ "parse", Document_parse },
	{ "parseFile", Document_parseFile },

	{ "__gc", Userdata<Document>::metamethod_gc },
	{ "__tostring", Userdata<Document>::metamethod_tostring },

	{ "get", Document_get },
	{ "set", Document_set },
	{ "__index", Document_get },
	{ "__newindex", Document_set },

	{ NULL, NULL }
};


template <>
const luaL_Reg* Userdata<Document>::methods() {
	return reg;
}
