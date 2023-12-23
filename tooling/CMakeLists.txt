# set minimum cmake version
cmake_minimum_required(VERSION 3.26)

# set project name
project(wasmtools)

# set c++ standard
set(CMAKE_CXX_STANDARD 20)

# set output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

include_directories(${CMAKE_SOURCE_DIR}/wasm-utils)

file(GLOB WASM_UTILS_SRC ${CMAKE_SOURCE_DIR}/wasm-utils/*.cpp)
file(GLOB WASM_UTILS_HEADERS ${CMAKE_SOURCE_DIR}/wasm-utils/*.hpp)
file(GLOB WASM_TRANSFORM_SRC ${CMAKE_SOURCE_DIR}/wasm-transform/*.cpp)
file(GLOB WASM_PACKAGE_SRC ${CMAKE_SOURCE_DIR}/wasm-package/*.cpp)

include_directories(${CMAKE_SOURCE_DIR}/wasm-utils)

# set linker flags if EMSCRIPTEN
if(EMSCRIPTEN)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS=_main,_free,_malloc -s EXPORTED_RUNTIME_METHODS=FS,PROXYFS,ERRNO_CODES,allocateUTF8 -lproxyfs.js --js-library=${CMAKE_SOURCE_DIR}/../emlib/fsroot.js -lidbfs.js -flto -O3")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto -O3")
endif()

add_executable(wasm-transform ${WASM_TRANSFORM_SRC} ${WASM_UTILS_SRC} ${WASM_UTILS_HEADERS})
add_executable(wasm-package ${WASM_PACKAGE_SRC} ${WASM_UTILS_SRC} ${WASM_UTILS_HEADERS})