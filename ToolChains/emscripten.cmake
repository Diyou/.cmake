include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)
# TODO disable until functional
unset(CMAKE_CXX_MODULE_STD)
unset(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
RunOnlyOnce()

if(WIN32)
    set(emsdk "emsdk.bat")
    set(emsdk_env "emsdk_env.bat")
else()
    set(emsdk "emsdk")
    set(emsdk_env "source ./emsdk_env.sh")
endif()

set(EMSDK "${CMAKE_CURRENT_SOURCE_DIR}/$ENV{EMSDK}")

function(UpdateEMSDK)
    execute_process(COMMAND ${GIT_EXECUTABLE} pull
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_VARIABLE output
    )
endfunction()
function(UpdateEmscripten)
    execute_process(COMMAND ${./}${emsdk}
        install latest
        WORKING_DIRECTORY "${EMSDK}"
    )
    execute_process(COMMAND ${./}${emsdk}
        activate latest
        WORKING_DIRECTORY "${EMSDK}"
        OUTPUT_VARIABLE output
    )
endfunction()

function(DownloadEMSDK destination)
    execute_process(COMMAND ${GIT_EXECUTABLE}
        clone https://github.com/emscripten-core/emsdk "${destination}"
    )
endfunction()

if(EXISTS $ENV{EMSCRIPTEN})
    set(EMSCRIPTEN_ROOT "$ENV{EMSCRIPTEN}")
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
        if(DOTCMAKE_EMSDK_AUTOUPDATE)
            UpdateEMSDK()
            UpdateEmscripten()
        endif()
    endif()
    set(EMSCRIPTEN_ROOT "${EMSDK}/upstream/emscripten")
endif()

include("${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake")

# ports
set(SDL2_DIR "${EMSCRIPTEN_ROOT}/tools/ports/sdl2")
set(SDL3_DIR "${EMSCRIPTEN_ROOT}/tools/ports/sdl3")
