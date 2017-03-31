cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)

project(lua-rapidjson)

# compile in release  mode by default
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

if(NOT LUA_RAPIDJSON_VERSION)
    find_package(Git)
    if(GIT_FOUND)
        execute_process(COMMAND ${GIT_EXECUTABLE} describe --dirty
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            OUTPUT_VARIABLE LUA_RAPIDJSON_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()
endif()

if (LUA_RAPIDJSON_VERSION)
    message("-- LUA_RAPIDJSON_VERSION: ${LUA_RAPIDJSON_VERSION}")
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
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -fPIC -march=native")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -fPIC -march=native")
else(UNIX)
    if(WIN32)
        set(PLAT "win32")
        add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB -D_CRT_SECURE_NO_WARNINGS)
    else(WIN32)
        set(PLAT "unsupported")
    endif(WIN32)
endif(UNIX)

if(NOT LUA_INCLUDE_DIR OR (WIN32 AND NOT LUA_LIBRARIES))
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
  find_package(Lua REQUIRED)
endif()

if (NOT RAPIDJSON_INCLUDE_DIRS)
  set(RAPIDJSON_INCLUDE_DIRS rapidjson/include)
endif()

include_directories(${LUA_INCLUDE_DIR} ${RAPIDJSON_INCLUDE_DIRS})

set(SOURCES
    src/Document.cpp
    src/Schema.cpp
    src/Userdata.hpp
    src/file.hpp
    src/luax.hpp
    src/rapidjson.cpp
    src/values.cpp
    src/values.hpp
)

add_library(lua-rapidjson MODULE ${SOURCES})
target_compile_features(lua-rapidjson PRIVATE cxx_rvalue_references)
source_group(src FILES ${SOURCES})

if (WIN32)
    target_link_libraries(lua-rapidjson ${LUA_LIBRARIES})
endif()

if (LINK_FLAGS)
    set_target_properties(lua-rapidjson PROPERTIES
        LINK_FLAGS ${LINK_FLAGS}
    )
endif()

set_target_properties(lua-rapidjson PROPERTIES
    OUTPUT_NAME "rapidjson"
    PREFIX ""
)


if (CMAKE_INSTALL_PREFIX)
  install(TARGETS lua-rapidjson DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")
endif(CMAKE_INSTALL_PREFIX)
