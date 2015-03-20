extern "C" {
#include <lua.h>
#include <lauxlib.h>
}
#include "rapidjson/rapidjson.h"
#include "rapidjson/document.h"
#include "rapidjson/reader.h"
#include <vector>

static int json_null(lua_State* L);

struct Ctx {
	virtual void submit(lua_State* L) = 0;
	virtual ~Ctx() {}
};

struct TopCtx : public Ctx {
	virtual void submit(lua_State* L) {}
};

struct ObjectCtx :public Ctx {
	ObjectCtx(int table) : table_(table) {}
	virtual void submit(lua_State* L)
	{
		lua_rawset(L, table_);
	}
private:
	int table_;
};

struct ArrayCtx : public Ctx {
	ArrayCtx(int table) : table_(table), index(1) {}
	virtual void submit(lua_State* L)
	{
		lua_rawseti(L, table_, index);
		++index;
	}
private:
	int table_;
	int index;

};

struct ToLuaHandler {
	ToLuaHandler(lua_State* aL) : L(aL) { current_ = &root; }
	inline bool status() {
		return !stack_.empty();
	}
	bool Null() {
		json_null(L);
		current_->submit(L);
		return status();
	}
	bool Bool(bool b) {
		lua_pushboolean(L, b);
		current_->submit(L);
		return status();
	}
	bool Int(int i) {
		lua_pushinteger(L, i);
		current_->submit(L);
		return status();
	}
	bool Uint(unsigned u) {
		lua_pushinteger(L, u);
		current_->submit(L);
		return status();
	}
	bool Int64(int64_t i) {
		lua_pushinteger(L, i);
		current_->submit(L);
		return status();
	}
	bool Uint64(uint64_t u) {
		lua_pushinteger(L, u);
		current_->submit(L);
		return status();
	}
	bool Double(double d) {
		lua_pushnumber(L, d);
		current_->submit(L);
		return !stack_.empty();
	}
	bool String(const char* str, rapidjson::SizeType length, bool copy) {
		lua_pushlstring(L, str, length);
		current_->submit(L);
		return status();
	}
	bool StartObject() {
		lua_createtable(L, 0, 4);
		stack_.push_back(current_);
		current_ = new ObjectCtx(lua_gettop(L));
		return true;
	}
	bool Key(const char* str, rapidjson::SizeType length, bool copy) {
		lua_pushlstring(L, str, length);
		return true;
	}
	bool EndObject(rapidjson::SizeType memberCount) {
		delete current_;
		current_ = stack_.back();
		stack_.pop_back();
		current_->submit(L);
		return true;
	}
	bool StartArray() {
		lua_createtable(L, 4, 0);
		stack_.push_back(current_);
		current_ = new ArrayCtx(lua_gettop(L));
		return true;
	}
	bool EndArray(rapidjson::SizeType elementCount) {
		delete current_;
		current_ = stack_.back();
		stack_.pop_back();
		current_->submit(L);
		return true;
	}
private:
	lua_State* L;
	TopCtx root;
	std::vector < Ctx* > stack_;
	Ctx* current_;
};

static int json_load(lua_State* L)
{
	size_t len = 0;

	const char* contents = luaL_checklstring(L, 1, &len);

	if (len < 2 || lua_isnumber(L, 1))
	{
		lua_pushnil(L);
		return 1;
	}

	int top = lua_gettop(L);
	ToLuaHandler handler(L);
	rapidjson::Reader reader;
	rapidjson::StringStream ss(contents);
	reader.Parse(ss, handler);

	if (!lua_istable(L, -1))
	{
		lua_settop(L, top);
		lua_pushnil(L);
	}

    return 1;
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
  {"load", json_load},
  {"dump", json_dump},
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
