#include <lua.hpp>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <rapidjson/istreamwrapper.h>
#include <rapidjson/schema.h>

#include "Userdata.hpp"

using namespace rapidjson;

template<>
const char* const Userdata<SchemaDocument>::metatable = "rapidjson.SchemaDocument";

template<>
SchemaDocument* Userdata<SchemaDocument>::construct(lua_State * L)
{
	auto doc = Userdata<Document>::check(L, 1);
	return new SchemaDocument(*doc);
}



template <>
const luaL_Reg* Userdata<SchemaDocument>::methods() {
	static const luaL_Reg reg[] = {
		{ "__gc", metamethod_gc },

		{ nullptr, nullptr }
	};
	return reg;
}


template<>
const char* const Userdata<SchemaValidator>::metatable = "rapidjson.SchemaValidator";

template<>
SchemaValidator* Userdata<SchemaValidator>::construct(lua_State * L)
{
	auto sd = Userdata<SchemaDocument>::check(L, 1);
	return new SchemaValidator(*sd);
}

static int SchemaValidator_reset(lua_State* L) {
	auto validator = Userdata<SchemaValidator>::check(L, 1);
	validator->Reset();
	return 0;
}


template <>
const luaL_Reg* Userdata<SchemaValidator>::methods() {
	static const luaL_Reg reg[] = {
		{ "__gc", metamethod_gc },
		{ "reset", SchemaValidator_reset },
		{ nullptr, nullptr }
	};
	return reg;
}


