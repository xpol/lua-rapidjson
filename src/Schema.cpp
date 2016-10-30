#include <lua.hpp>

#include <rapidjson/document.h>
#include <rapidjson/error/en.h>
#include <rapidjson/istreamwrapper.h>
#include <rapidjson/schema.h>
#include <rapidjson/stringbuffer.h>

#include "Userdata.hpp"
#include "values.hpp"

using namespace rapidjson;

template<>
const char* const Userdata<SchemaDocument>::metatable = "rapidjson.SchemaDocument";

template<>
SchemaDocument* Userdata<SchemaDocument>::construct(lua_State * L)
{
    switch (lua_type(L, 1)) {
        case LUA_TNONE:
            return new SchemaDocument(Document()); // empty schema
        case LUA_TSTRING: {
            auto d = Document();
            size_t len = 0;
            const char* s = lua_tolstring(L, 1, &len);
            d.Parse(s, len);
            return new SchemaDocument(d);
        }
        case LUA_TTABLE: {
            auto doc = Document();
            values::toDocument(L, 1, &doc);
            return new SchemaDocument(doc);
        }
        case LUA_TUSERDATA:{
            auto doc = Userdata<Document>::check(L, 1);
            return new SchemaDocument(*doc);
        }
        default:
            luaL_typerror(L, 1, "none, string, table or rapidjson.Document");
            return nullptr; // Just make compiler happy
    }
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


static int SchemaValidator_validate(lua_State* L) {
    auto validator = Userdata<SchemaValidator>::check(L, 1);
    auto doc = Userdata<Document>::check(L, 2);
    lua_pushboolean(L, doc->Accept(*validator));
    return 1;
}


/**
 * local keyword, docpointer, schemapointer = validator:error()
 */
static int SchemaValidator_error(lua_State* L) {
    auto validator = Userdata<SchemaValidator>::check(L, 1);
    if (validator->IsValid()) {
        lua_pushnil(L);
        return 1;
    }
        
    // keyword
    lua_pushstring(L, validator->GetInvalidSchemaKeyword());
    
    // docuement pointer
    StringBuffer sb;
    validator->GetInvalidDocumentPointer().StringifyUriFragment(sb);
    lua_pushlstring(L, sb.GetString(), sb.GetSize());
    
    
    // schema pointer
    sb.Clear();
    validator->GetInvalidSchemaPointer().StringifyUriFragment(sb);
    lua_pushlstring(L, sb.GetString(), sb.GetSize());
    
    return 3;
}

template <>
const luaL_Reg* Userdata<SchemaValidator>::methods() {
	static const luaL_Reg reg[] = {
		{ "__gc", metamethod_gc },
		{ "reset", SchemaValidator_reset },
        { "validate", SchemaValidator_validate },
        { "error", SchemaValidator_error },
		{ nullptr, nullptr }
	};
	return reg;
}
