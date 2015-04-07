cmake_minimum_required(VERSION 2.8)

project (rapidjson)

if (LUA_RAPIDJSON_VERSION)
    add_definitions(-DLUA_RAPIDJSON_VERSION="${LUA_RAPIDJSON_VERSION}")
endif()

if(UNIX)
    if(APPLE)
        set(PLAT "macosx")
        set(LINK_FLAGS "-bundle -undefined dynamic_lookup -all_load")
    else(APPLE)
        set(PLAT "linux")
        set(LINK_FLAGS "-shared")
    endif(APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -fPIC")
else(UNIX)
    if(WIN32)
        set(PLAT "win32")
        add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB)
    else(WIN32)
        set(PLAT "unsupported")
    endif(WIN32)
endif(UNIX)


if (RELEASE)
	add_definitions(-O2 -DNDEBUG)
endif()

if (NOT LUA_INCLUDE_DIR)
    message("Using system lua...")
    find_package(Lua REQUIRED)
endif()

include_directories(${LUA_INCLUDE_DIR} rapidjson/include)

add_library (json MODULE src/rapidjson.cpp)

if (LUA_LIBRARIES)
    message("Using LUALIB:${LUA_LIBRARIES}")
    target_link_libraries(json ${LUA_LIBRARIES})
endif()

if (LINK_FLAGS)
    set_target_properties(json PROPERTIES
        LINK_FLAGS ${LINK_FLAGS}
    )
endif()

set_target_properties(json PROPERTIES
    OUTPUT_NAME "rapidjson"
    PREFIX ""
)


if (CMAKE_INSTALL_PREFIX)
  install(TARGETS json DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")
endif(CMAKE_INSTALL_PREFIX)
