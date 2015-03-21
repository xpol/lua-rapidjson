#include <cstdio>
#include <vector>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
}

#include "rapidjson/rapidjson.h"
#include "rapidjson/document.h"
#include "rapidjson/encodings.h"
#include "rapidjson/error/en.h"
#include "rapidjson/error/error.h"
#include "rapidjson/filereadstream.h"
#include "rapidjson/reader.h"

using namespace rapidjson;

static int json_null(lua_State* L);

struct ToLuaHandler;



struct Ctx {
	Ctx(): fn_(&topFn){}
	Ctx(const Ctx& rhs): table_(rhs.table_), index(rhs.index), fn_(rhs.fn_)
	{
	}
	const Ctx& operator=(const Ctx& rhs){
		if (this != &rhs) {
			table_ = rhs.table_;
			index = rhs.index;
			fn_ = rhs.fn_;
		}
		return *this;
	}
	static Ctx Object(int table) {
		return Ctx(table, &objectFn);
	}
	static Ctx Array(int table)
	{
		return Ctx(table, &arrayFn);
	}
	void submit(lua_State* L)
	{
		fn_(L, this);
	}
private:
	Ctx(int table, void(*f)(lua_State* L, Ctx* ctx)) : table_(table), index(1), fn_(f) {}

	int table_;
	int index;
	void(*fn_)(lua_State* L, Ctx* ctx);

	static void objectFn(lua_State* L, Ctx* ctx)
	{
		lua_rawset(L, ctx->table_);
	}

	static void arrayFn(lua_State* L, Ctx* ctx)
	{
		lua_rawseti(L, ctx->table_, ctx->index++);
	}
	static void topFn(lua_State* L, Ctx* ctx)
	{
	}
};

struct ToLuaHandler {
	ToLuaHandler(lua_State* aL) : L(aL), hasError(true) {stack_.reserve(32);}

	bool Null() {
		json_null(L);
		current_.submit(L);
		return true;
	}
	bool Bool(bool b) {
		lua_pushboolean(L, b);
		current_.submit(L);
		return true;
	}
	bool Int(int i) {
		lua_pushinteger(L, i);
		current_.submit(L);
		return true;
	}
	bool Uint(unsigned u) {
		lua_pushinteger(L, u);
		current_.submit(L);
		return true;
	}
	bool Int64(int64_t i) {
		lua_pushinteger(L, i);
		current_.submit(L);
		return true;
	}
	bool Uint64(uint64_t u) {
		lua_pushinteger(L, u);
		current_.submit(L);
		return true;
	}
	bool Double(double d) {
		lua_pushnumber(L, d);
		current_.submit(L);
		return true;
	}
	bool String(const char* str, SizeType length, bool copy) {
		lua_pushlstring(L, str, length);
		current_.submit(L);
		return true;
	}
	bool StartObject() {
		lua_createtable(L, 0, 0);
		stack_.push_back(current_);
		current_ = Ctx::Object(lua_gettop(L));
		return true;
	}
	bool Key(const char* str, SizeType length, bool copy) {
		lua_pushlstring(L, str, length);
		return true;
	}
	bool EndObject(SizeType memberCount) {
		current_ = stack_.back();
		stack_.pop_back();
		current_.submit(L);
		hasError = false;
		return true;
	}
	bool StartArray() {
		lua_createtable(L, 0, 0);
		stack_.push_back(current_);
		current_ = Ctx::Array(lua_gettop(L));
		return true;
	}
	bool EndArray(SizeType elementCount) {
		current_ = stack_.back();
		stack_.pop_back();
		current_.submit(L);
		hasError = false;
		return true;
	}
	bool hasError;
private:
	lua_State* L;
	std::vector < Ctx > stack_;
	Ctx current_;
};

template<typename Stream>
inline int decode(lua_State* L, Stream* s)
{
	int top = lua_gettop(L);
	ToLuaHandler handler(L);
	Reader reader;
	ParseResult r = reader.Parse(*s, handler);

	if (!r || handler.hasError) {
		lua_settop(L, top);
		lua_pushnil(L);
		if (r.Code() == kParseErrorNone && handler.hasError)
			lua_pushliteral(L, "A JSON payload should be an object or array.");
		else
			lua_pushfstring(L, "%s (%d)", GetParseError_En(r.Code()), r.Offset());
		return 2;
	}

	return 1;
}

static int json_decode(lua_State* L)
{
	size_t len = 0;

	const char* contents = luaL_checklstring(L, 1, &len);
	StringStream s(contents);
	return decode(L, &s);

}

static int json_encode(lua_State* L)
{
	return 0;
}

static int json_load(lua_State* L)
{
	const char* filename = luaL_checklstring(L, 1, NULL);
	FILE* fp = NULL;
#if WIN32
	fopen_s(&fp, filename, "rb");
#else
	fp = fopen(filename, "r");
#endif
	if (fp == NULL)
	{
		lua_pushnil(L);
		lua_pushliteral(L, "error while open file");
		return 2;
	}

	static const size_t BufferSize = 16*1024;
	std::vector<char> readBuffer(BufferSize);
	FileReadStream fs(fp, &readBuffer.front(), BufferSize);
	int n = decode(L, &fs);
	fclose(fp);
	return n;
}

static int json_dump(lua_State* L)
{
    return 0;
}

static int null = LUA_NOREF;

/**
 * Returns json.null.
 */
static int json_null(lua_State* L)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, null);
	return 1;
}

static const luaL_Reg methods[] = {
	// string <--> json
	{"decode", json_decode},
	{"encode", json_encode},

	// file <--> json
	{"load", json_load},
	{"dump", json_dump},

	// null place holder
	{"null", json_null},
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

	lua_getfield(L, -1, "null");
	null = luaL_ref(L, LUA_REGISTRYINDEX);

    return 1;
}

}
