include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)
RunOnlyOnce()

if(WIN32)
    set(emsdk "emsdk.bat")
    set(emsdk_env "emsdk_env.bat")
else()
    set(emsdk "emsdk")
    set(emsdk_env "source ./emsdk_env.sh")
endif()

set(EMSDK "${PROJECT_ROOT}/$ENV{EMSDK}")

macro(UpdateEMSDK)
    execute_process(COMMAND ${GIT_EXECUTABLE} pull
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_VARIABLE output
    )
endmacro()
macro(UpdateEmscripten)
    execute_process(COMMAND ${./}${emsdk}
        install latest
        WORKING_DIRECTORY "${EMSDK}"
    )
    execute_process(COMMAND ${./}${emsdk}
        activate latest
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_VARIABLE output
    )
endmacro()

function(DownloadEMSDK destination)
    execute_process(COMMAND ${GIT_EXECUTABLE}
        clone https://github.com/emscripten-core/emsdk "${destination}"
    )
endfunction()

if(DEFINED ENV{EMSCRIPTEN_ROOT})
    set(EMSCRIPTEN_ROOT "$ENV{EMSCRIPTEN_ROOT}")
else()
    if(NOT EXISTS ${EMSDK} OR NOT EXISTS ${EMSDK}/${emsdk})
        file(GLOB not_empty "${EMSDK}/*")
        if(EXISTS ${EMSDK} AND not_empty)
            message(FATAL_ERROR "EMSDK not found but directory is not empty to install")
        else()
            DownloadEMSDK(${EMSDK})
            UpdateEmscripten()
        endif()
    else()
        if(DOTCMAKE_EMSDK_AUTOUPDATE
        AND NOT CMAKE_IN_TRY_COMPILE)
            UpdateEMSDK()
            UpdateEmscripten()
        endif()
    endif()
    set(EMSCRIPTEN_ROOT "${EMSDK}/upstream/emscripten")
endif()

function(PrepareEmscriptenPort port)
    execute_process(COMMAND ${./}emcc
        --show-ports
        WORKING_DIRECTORY "${EMSCRIPTEN_ROOT}"
        OUTPUT_VARIABLE ports
    )
    set(prefix --use-port=)
    string(REGEX MATCHALL "${prefix}([^;)]+)[;)]" ports "${ports}")


    if(NOT ${prefix}${${port}} IN_LIST ports)
        message(FATAL_ERROR "Emscripten port ${${port}} not found")
        return()
    endif()

    execute_process(COMMAND ${./}embuilder
        build ${${port}}
        WORKING_DIRECTORY "${EMSCRIPTEN_ROOT}"
        OUTPUT_VARIABLE ports
        RESULT_VARIABLE result
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Failed building Emscripten port ${${port}}")
        return()
    endif()

    if( ${port} STREQUAL sdl2 OR
        ${port} STREQUAL sdl3
    )
        find_package(${${port}} REQUIRED CONFIG)
    else()
        message(STATUS "Add [compile+link] flags ${prefix}${${port}}")
    endif()
endfunction()

include("${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake")
if(EMSCRIPTEN_VERSION VERSION_LESS 6.0.1)
    unset(CMAKE_CXX_MODULE_STD)
    unset(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
endif()
