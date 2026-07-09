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

function(GetPorts)
    execute_process(COMMAND ${./}emcc --show-ports
        WORKING_DIRECTORY "${EMSCRIPTEN_ROOT}"
        OUTPUT_VARIABLE PORTS
    )
    set(_REGEX [[--use-port=([^ ;)]+)]])
    string(REGEX MATCHALL ${_REGEX} PORTS "${PORTS}")
    list(TRANSFORM PORTS REPLACE ${_REGEX} \\1)
    set(EMSCRIPTEN_PORTS ${PORTS} CACHE INTERNAL "Emscripten ports" FORCE)
endfunction()

macro(UpdateEMSDK)
    execute_process(COMMAND ${GIT_EXECUTABLE} pull
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_QUIET
    )
endmacro()
macro(UpdateEmscripten)
    execute_process(COMMAND ${./}${emsdk} install latest
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_QUIET
    )
    execute_process(COMMAND ${./}${emsdk} activate latest
        ERROR_QUIET
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_QUIET
    )
    GetPorts()
endmacro()

function(DownloadEMSDK destination)
    execute_process(COMMAND ${GIT_EXECUTABLE}
        clone https://github.com/emscripten-core/emsdk "${destination}"
    )
endfunction()

if(DEFINED ENV{EMSCRIPTEN_ROOT})
    set(EMSCRIPTEN_ROOT "$ENV{EMSCRIPTEN_ROOT}")
else()
    set(EMSCRIPTEN_ROOT "${EMSDK}/upstream/emscripten")
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
endif()
if(NOT DEFINED EMSCRIPTEN_PORTS)
    GetPorts()
endif()

function(UseEmscriptenPort name)
    string(TOLOWER ${${name}} port)

    # Aliases
    if(port STREQUAL dawn)
        set(port emdawnwebgpu)
    endif()

    if(NOT port IN_LIST EMSCRIPTEN_PORTS)
        return()
    endif()

    execute_process(COMMAND ${./}embuilder build ${port}
        WORKING_DIRECTORY "${EMSCRIPTEN_ROOT}"
        ERROR_QUIET
        RESULT_VARIABLE result
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Failed building Emscripten port ${port}")
        return()
    endif()

    find_package(${port} CONFIG QUIET)
    if(NOT ${port}_FOUND)
        add_compile_options(--use-port=${port})
        add_link_options(--use-port=${port})
    endif()

    set(${${name}}_FOUND TRUE PARENT_SCOPE)
endfunction()

add_compile_options(-Wno-experimental)

include("${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake")
if(EMSCRIPTEN_VERSION VERSION_LESS 6.0.1)
    unset(CMAKE_CXX_MODULE_STD)
    unset(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
endif()
