#include <limits>
#include <cstdio>
#include <cmath>
#include <vector>
#include <algorithm>
#include <string>

#include "lua.hpp"

#include "rapidjson/document.h"
#include "rapidjson/encodedstream.h"
#include "rapidjson/encodings.h"
#include "rapidjson/error/en.h"
#include "rapidjson/error/error.h"
#include "rapidjson/filereadstream.h"
#include "rapidjson/filewritestream.h"
#include "rapidjson/rapidjson.h"
#include "rapidjson/reader.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#include "rapidjson/prettywriter.h"

using namespace rapidjson;

#ifndef LUA_RAPIDJSON_VERSION
#define LUA_RAPIDJSON_VERSION "scm"
#endif

static const char* JSON_TABLE_TYPE_FIELD = "__jsontype";
enum json_table_type {
	JSON_TABLE_TYPE_OBJECT = 0,
	JSON_TABLE_TYPE_ARRAY = 1,
	JSON_TABLE_TYPE_MAX
};

static const char* JSON_TABLE_TYPE_NAMES[JSON_TABLE_TYPE_MAX] = { "object", "array" };
static const char* JSON_TABLE_TYPE_METAS[JSON_TABLE_TYPE_MAX] = { "json.object", "json.array" };


static void setfuncs(lua_State* L, const luaL_Reg *funcs)
{
#if LUA_VERSION_NUM >= 502 // LUA 5.2 or above
	luaL_setfuncs(L, funcs, 0);
#else
	luaL_register(L, NULL, funcs);
#endif
}


#if LUA_VERSION_NUM < 502
#define lua_rawlen   lua_objlen
#endif



static FILE* openForRead(const char* filename)
{
	FILE* fp = NULL;
#if WIN32
	fopen_s(&fp, filename, "rb");
#else
	fp = fopen(filename, "r");
#endif

	return fp;
}

static FILE* openForWrite(const char* filename)
{
	FILE* fp = NULL;
#if WIN32
	fopen_s(&fp, filename, "wb");
#else
	fp = fopen(filename, "w");
#endif

	return fp;
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

static void createSharedMeta(lua_State* L, json_table_type type)
{
	luaL_newmetatable(L, JSON_TABLE_TYPE_METAS[type]); // [meta]
	lua_pushstring(L, JSON_TABLE_TYPE_NAMES[type]); // [meta, name]
	lua_setfield(L, -2, JSON_TABLE_TYPE_FIELD); // [meta]
	lua_pop(L, 1); // []
}

static int makeTableType(lua_State* L, int idx, json_table_type type)
{
	bool isnoarg = lua_isnoneornil(L, idx);
	bool istable = lua_istable(L, idx);
	if (!isnoarg && !istable)
		return luaL_argerror(L, idx, "optional table excepted");

	if (isnoarg)
		lua_createtable(L, 0, 0); // [table]
	else // is table.
	{
		lua_pushvalue(L, idx); // [table]
		if (lua_getmetatable(L, -1))
		{
			// already have a metatable, just set the __jsontype field.
			// [table, meta]
			lua_pushstring(L, JSON_TABLE_TYPE_NAMES[type]); // [table, meta, name]
			lua_setfield(L, -2, JSON_TABLE_TYPE_FIELD); // [table, meta]
			lua_pop(L, 1); // [table]
			return 1;
		}
		// else fall through
	}

	// Now we have a table without meta table
	luaL_getmetatable(L, JSON_TABLE_TYPE_METAS[type]); // [table, meta]
	lua_setmetatable(L, -2); // [table]
	return 1;
}

static int json_object(lua_State* L)
{
	return makeTableType(L, 1, JSON_TABLE_TYPE_OBJECT);
}

static int json_array(lua_State* L)
{
	return makeTableType(L, 1, JSON_TABLE_TYPE_ARRAY);
}


struct Ctx {
	Ctx() : fn_(&topFn){}
	Ctx(const Ctx& rhs) : table_(rhs.table_), index(rhs.index), fn_(rhs.fn_)
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
	ToLuaHandler(lua_State* aL) : L(aL) { stack_.reserve(32); }

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
		lua_createtable(L, 0, 0); // [..., object]

		// mark as object.
		luaL_getmetatable(L, "json.object");  //[..., object, json.object]
		lua_setmetatable(L, -2); // [..., object]

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
		return true;
	}
	bool StartArray() {
		lua_createtable(L, 0, 0);

		// mark as array.
		luaL_getmetatable(L, "json.array");  //[..., array, json.array]
		lua_setmetatable(L, -2); // [..., array]

		stack_.push_back(current_);
		current_ = Ctx::Array(lua_gettop(L));
		return true;
	}
	bool EndArray(SizeType elementCount) {
		current_ = stack_.back();
		stack_.pop_back();
		current_.submit(L);
		return true;
	}
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

	if (!r) {
		lua_settop(L, top);
		lua_pushnil(L);
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



static int json_load(lua_State* L)
{
	const char* filename = luaL_checklstring(L, 1, NULL);
	FILE* fp = openForRead(filename);
	if (fp == NULL)
	{
		lua_pushnil(L);
		lua_pushliteral(L, "error while open file");
		return 2;
	}

	static const size_t BufferSize = 16 * 1024;
	std::vector<char> readBuffer(BufferSize);
	FileReadStream fs(fp, &readBuffer.front(), BufferSize);
	AutoUTFInputStream<unsigned, FileReadStream> eis(fs);
	int n = decode(L, &eis);
	fclose(fp);
	return n;
}

struct restore_stack{
	restore_stack(lua_State* state) : top(lua_gettop(state)), L(state) {}
	~restore_stack() { lua_settop(L, top); }
	int top;
private:
	lua_State* L;
};

struct Key
{
	Key(const char* k, SizeType l) : key(k), size(l) {}
	bool operator<(const Key& rhs) const {
		return strcmp(key, rhs.key) < 0;
	}
	const char* key;
	SizeType size;
};




class Encoder {
public:
	Encoder(lua_State*L, int opt) : pretty(false), sort_keys(false)
	{
		if (lua_isnoneornil(L, opt))
			return;
		luaL_checktype(L, opt, LUA_TTABLE);

		lua_pushvalue(L, opt); // [table]
		booleanField(L, "pretty", &pretty);
		booleanField(L, "sort_keys", &sort_keys);
	}

private:
	void booleanField(lua_State* L, const char* name,bool* value)
	{
		restore_stack save(L);
		lua_getfield(L, -1, name);  // [field]
		if (lua_isnoneornil(L, -1))
			return;
		if (!lua_isboolean(L, -1))
			return;
		*value = lua_toboolean(L, -1) != 0;
	}

	bool pretty;
	bool sort_keys;

	static bool isJsonNull(lua_State* L, int idx)
	{
		lua_pushvalue(L, idx); // [value]

		json_null(L); // [value, json.null]

		bool is = lua_rawequal(L, -1, -2) != 0;

		lua_pop(L, 2); // []

		return is;
	}

	static bool isInteger(lua_State* L, int idx, int64_t* out)
	{
#if LUA_VERSION_NUM >= 503
		if (lua_isinteger(L, idx)) // but it maybe not detect all integers.
        {
            *out = lua_tointeger(L, idx);
            return true;
        }
#endif
        double intpart;
        if (modf(lua_tonumber(L, idx), &intpart) == 0.0)
        {
            if (std::numeric_limits<lua_Integer>::min() <= intpart
            && intpart <= std::numeric_limits<lua_Integer>::max())
            {
                *out = (int64_t)intpart;
                return true;
            }
        }
		return false;
	}


	static bool hasJsonType(lua_State* L, int idx, bool& isarray)
	{
		restore_stack keep(L);
		lua_pushvalue(L, idx); // [value]

		lua_getmetatable(L, -1); // [value, meta]
		lua_getfield(L, -1, JSON_TABLE_TYPE_FIELD); // [value, meta, meta.__jsontype]
		if (lua_isnoneornil(L, -1))
			return false;
		lua_pushvalue(L, -1);// [value, meta, meta.__jsontype, meta.__jsontype]

		size_t len;
		const char* s = lua_tolstring(L, -1, &len);
		isarray = (s != NULL && strncmp(s, "array", 6) == 0);
		return true;
	}

	static bool isArray(lua_State* L, int idx)
	{
		bool isarray = false;
		if (hasJsonType(L, idx, isarray))
			return isarray;

		return (lua_rawlen(L, idx) != 0);
	}

	static bool isArray(lua_State* L, int idx, const std::vector<Key>& keys)
	{
		bool isarray = false;
		if (hasJsonType(L, idx, isarray))
			return isarray;

		if (keys.empty()) // empty table without meta field are trade as object
			return false;

		return (lua_rawlen(L, idx) == keys.size()); // key number is same as # are trade as array
	}


	template<typename Writer>
	bool encodeValue(lua_State* L, Writer* writer, int idx)
	{
		restore_stack keep(L);

		size_t len;
		const char* s;
		int64_t integer;
		lua_pushvalue(L, idx); // [value]
		int t = lua_type(L, -1);
		switch (t) {
		case LUA_TBOOLEAN:
			writer->Bool(lua_toboolean(L, -1) != 0);
			return true;
		case LUA_TNUMBER:
			if (isInteger(L, -1, &integer))
				writer->Int64(integer);
			else
				writer->Double(lua_tonumber(L, -1));
			return true;
		case LUA_TSTRING:
			s = lua_tolstring(L, -1, &len);
			writer->String(s, static_cast<SizeType>(len));
			return true;
		case LUA_TTABLE:
			return encodeTable(L, writer, -1);
		case LUA_TFUNCTION:
			if (isJsonNull(L, -1))
			{
				writer->Null();
				return true;
			}
			// otherwise fall thought
		case LUA_TLIGHTUSERDATA: // fall thought
		case LUA_TUSERDATA: // fall thought
		case LUA_TTHREAD: // fall thought
		case LUA_TNONE: // fall thought
		case LUA_TNIL: // fall thought
		default:
			std::string s("can't encode ");
			s += lua_typename(L, t);
			//luaL_argerror(L, 1, s.data()); // never returns.
			return false;
		}
	}

	template<typename Writer>
	bool encodeTable(lua_State* L, Writer* writer, int idx)
	{
		restore_stack restore(L);
		lua_pushvalue(L, idx); // [table]

		if (!sort_keys)
			return isArray(L, -1) ?
				encodeArray(L, writer) :
				encodeObject(L, writer);

		lua_pushnil(L); // [table, nil]
		std::vector<Key> keys;

		while (lua_next(L, -2))
		{
			// [table, key, value]
			lua_pushvalue(L, -2);
			// [table, key, value, key]

			size_t len = 0;
			const char *key = lua_tolstring(L, -1, &len);
			keys.push_back(Key(key, static_cast<SizeType>(len)));
			// pop value + copy of key, leaving original key
			lua_pop(L, 2);
			// [table, key]
		}
		// [table]
		return isArray(L, -1, keys) ?
			encodeArray(L, writer) :
			encodeObject(L, writer, keys);
	}

	template<typename Writer>
	bool encodeObject(lua_State* L, Writer* writer)
	{
		writer->StartObject();

		// [table]
		lua_pushnil(L); // [table, nil]
		while (lua_next(L, -2))
		{
			// [table, key, value]
			lua_pushvalue(L, -2);
			// [table, key, value, key]

			size_t len = 0;
			const char *key = lua_tolstring(L, -1, &len);
			writer->Key(key, static_cast<SizeType>(len));
			bool ok = encodeValue(L, writer, -2);
			// pop value + copy of key, leaving original key
			lua_pop(L, 2);
			// [table, key]
			if (!ok)
				return false;
		}
		// [table]
		writer->EndObject();
		return true;
	}

	template<typename Writer>
	bool encodeObject(lua_State* L, Writer* writer, std::vector<Key> &keys)
	{
		// [table]
		writer->StartObject();

		std::sort(keys.begin(), keys.end());

		const std::vector<Key>& const_keys = keys;
		std::vector<Key>::const_iterator i = const_keys.begin();
		std::vector<Key>::const_iterator e = const_keys.end();
		for (; i != e; ++i)
		{
			writer->Key(i->key, static_cast<SizeType>(i->size));
			lua_pushlstring(L, i->key, i->size); // [table, key]
			lua_gettable(L, -2); // [table, value]
			bool ok = encodeValue(L, writer, -1);
			lua_pop(L, 1); // [table]
			if (!ok)
				return false;
		}
		// [table]
		writer->EndObject();
		return true;
	}

	template<typename Writer>
	bool encodeArray(lua_State* L, Writer* writer)
	{
		// [table]
		writer->StartArray();
		int MAX = static_cast<int>(lua_rawlen(L, -1)); // lua_rawlen always returns value >= 0
		for (int n = 1; n <= MAX; ++n)
		{
			lua_rawgeti(L, -1, n); // [table, element]
			bool ok = encodeValue(L, writer, -1);
			lua_pop(L, 1); // [table]
			if (!ok)
				return false;
		}
		writer->EndArray();
		return true;
	}

public:
	template<typename Stream>
	bool encode(lua_State* L, Stream* s, int idx)
	{
		if (pretty)
		{
			PrettyWriter<Stream> writer(*s);
			return encodeValue(L, &writer, idx);
		}
		else
		{
			Writer<Stream> writer(*s);
			return encodeValue(L, &writer, idx);
		}
	}
};


static int json_encode(lua_State* L)
{
	Encoder encode(L, 2);

	StringBuffer s;

	if (!encode.encode(L, &s, 1))
	{
		lua_pushnil(L);
		lua_pushliteral(L, "can't encode to json.");
		return 2;
	}
	lua_pushlstring(L, s.GetString(), s.GetSize());
	return 1;
}


static int json_dump(lua_State* L)
{
	Encoder encoder(L, 3);

	FILE* fp = openForWrite(luaL_checkstring(L, 2));

	if (fp == NULL)
	{
		lua_pushboolean(L, false);
		lua_pushliteral(L, "error while open file");
		return 2;
	}

	static const size_t sz = 16 * 1024;
	std::vector<char> buffer(sz);
	FileWriteStream fs(fp, &buffer.front(), sz);
	bool ok = encoder.encode(L, &fs, 1);
	fclose(fp);
	lua_pushboolean(L, ok);
	if (ok)
		return 1;
	lua_pushliteral(L, "can't encode to json.");
	return 2;
}


static const luaL_Reg methods[] = {
	// string <--> json
	{ "decode", json_decode },
	{ "encode", json_encode },

	// file <--> json
	{ "load", json_load },
	{ "dump", json_dump },

	// special tags place holder
	{ "null", json_null },
	{ "object", json_object },
	{ "array", json_array },
	{ NULL, NULL }
};



extern "C" {

LUALIB_API int luaopen_rapidjson(lua_State* L)
{
	lua_newtable(L); // [rapidjson]

	setfuncs(L, methods); // [rapidjson]

	lua_pushliteral(L, "rapidjson"); // [rapidjson, name]
	lua_setfield(L, -2, "_NAME"); // [rapidjson]

	lua_pushliteral(L, LUA_RAPIDJSON_VERSION); // [rapidjson, version]
	lua_setfield(L, -2, "_VERSION"); // [rapidjson]

	lua_getfield(L, -1, "null"); // [rapidjson, json.null]
	null = luaL_ref(L, LUA_REGISTRYINDEX); // [rapidjson]

	createSharedMeta(L, JSON_TABLE_TYPE_OBJECT);
	createSharedMeta(L, JSON_TABLE_TYPE_ARRAY);

	return 1;
}

}
