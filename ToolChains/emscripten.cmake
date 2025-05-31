if(NOT EXISTS $ENV{EMSCRIPTEN})
    message(FATAL_ERROR "No emscripten found")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)
include("$ENV{EMSCRIPTEN}/cmake/Modules/Platform/Emscripten.cmake")
