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
#include <rapidjson/schema.h>
#include <rapidjson/stringbuffer.h>


using namespace  rapidjson;

template<>
const char* const Userdata<Document>::metatable = "rapidjson.Document";


template<>
Document* Userdata<Document>::construct(lua_State * L)
{
    auto t = lua_type(L, 1);
    if (t != LUA_TNONE && t != LUA_TSTRING && t != LUA_TTABLE) {
        luax::typerror(L, 1, "none, string or table");
        return nullptr;
    }

    auto doc = new Document();
    if (t == LUA_TSTRING) {
        size_t len;
        const char* s = luaL_checklstring(L, 1, &len);
        doc->Parse(s, len);
    }
    else if (t == LUA_TTABLE) {
        values::toDocument(L, 1, doc);
    }
    return doc;
}


static int pushParseResult(lua_State* L, Document* doc) {
	auto err = doc->GetParseError();
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
	auto s = luaL_checklstring(L, 2, &l);
	doc->Parse(s, l);

	return pushParseResult(L, doc);
}

static int Document_parseFile(lua_State* L) {
	auto doc = Userdata<Document>::get(L, 1);

	auto s = luaL_checkstring(L, 2);
	std::ifstream ifs(s);
	IStreamWrapper isw(ifs);

	doc->ParseStream(isw);

	return pushParseResult(L, doc);;
}


/**
 * doc:get('path'[, default])
 */
static int Document_get(lua_State* L) {
	auto doc = Userdata<Document>::check(L, 1);
	auto s = luaL_checkstring(L, 2);
	Pointer ptr(s);
	auto v = ptr.Get(*doc);

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
	auto doc = Userdata<Document>::check(L, 1);
	Pointer ptr(luaL_checkstring(L, 2));
	auto v = values::toValue(L, 3, doc->GetAllocator());

	ptr.Set(*doc, v, doc->GetAllocator());

	return 0;
}





template <>
const luaL_Reg* Userdata<Document>::methods() {
	static const luaL_Reg reg[] = {
		{ "parse", Document_parse },
		{ "parseFile", Document_parseFile },

		{ "__gc", metamethod_gc },
		{ "__tostring", metamethod_tostring },

		{ "get", Document_get },
		{ "set", Document_set },

		{ nullptr, nullptr }
	};
	return reg;
}
