cmake_minimum_required(VERSION 2.8)

project (json)



if(UNIX)
    if(APPLE)
        set(PLAT "macosx")
        set(LINK_FLAGS "-bundle -undefined dynamic_lookup -all_load")
    else(APPLE)
        set(PLAT "linux")
        set(LINK_FLAGS "-shared")
    endif(APPLE)
else(UNIX)
    if(WIN32)
        set(PLAT "win32")
        add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB)
    else(WIN32)
        set(PLAT "unsupported")
    endif(WIN32)
endif(UNIX)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -fPIC -O2")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -fPIC -O2")


if (RELEASE)
  add_definitions(-O2 -DNDEBUG)
endif(RELEASE)

if (NOT LUA_INCLUDE_DIR)
    find_package(Lua REQUIRED)
endif()

include_directories(${LUA_INCLUDE_DIR} rapidjson/include)

add_library (json MODULE src/json.cpp)


set_target_properties(json PROPERTIES
    LINK_FLAGS ${LINK_FLAGS}
    OUTPUT_NAME "json"
    PREFIX ""
)


if (CMAKE_INSTALL_PREFIX)
  install(TARGETS json DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")
endif(CMAKE_INSTALL_PREFIX)
