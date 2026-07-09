cmake_path(SET CMAKE_SOURCE_DIR NORMALIZE ${CMAKE_BINARY_DIR}/../..)
cmake_path(RELATIVE_PATH CMAKE_ARGV3
    BASE_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE SOURCE_FILE)

load_cache("${CMAKE_BINARY_DIR}" READ_WITH_PREFIX _ CMAKE_MAKE_PROGRAM)

string(REPLACE + [[\+]] SOURCE_FILE "${SOURCE_FILE}")
string(REPLACE . [[\.]] SOURCE_FILE "${SOURCE_FILE}")

string(CONFIGURE [[build ([^\n:]*@SOURCE_FILE@\.o):]] match @ONLY)

file(STRINGS "${CMAKE_BINARY_DIR}/build.ninja" matches REGEX ${match})

foreach(item ${matches})
    string(REGEX MATCH "${match}" item "${item}")
    message("Compile: ${CMAKE_MATCH_1}")
    execute_process(COMMAND ${_CMAKE_MAKE_PROGRAM}
        "${CMAKE_MATCH_1}"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
endforeach()
