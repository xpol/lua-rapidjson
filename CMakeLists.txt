cmake_minimum_required(VERSION 2.8)

project(json)

include(rapidjson/CMakeLists.txt)

if (NOT LUA_INCLUDE_DIRS)
  find_package(Lua REQUIRED)
endif(LUA_INCLUDE_DIRS)


add_library(json MODULE src/json.cpp)

if(APPLE)
  set(CMAKE_SHARED_MODULE_CREATE_C_FLAGS
    "${CMAKE_SHARED_MODULE_CREATE_C_FLAGS} -flat_namespace -undefined suppress"
  )
endif()


include_directories(${LUA_INCLUDE_DIRS})
target_link_libraries(json ${LUA_LIBRARIES})

if (CMAKE_INSTALL_PREFIX)
  install(TARGETS json DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")
endif(CMAKE_INSTALL_PREFIX)
