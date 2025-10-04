include_guard(GLOBAL)
function(ConfigureVScode)
    list(JOIN DEBUG_ARGS [[", "]] DEBUG_ARGS)

    if(CMAKE_SYSTEM_NAME STREQUAL Android)
        set(profile Android)
    elseif(EMSCRIPTEN)
        set(profile Emscripten)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES Clang)
        set(profile Clang)
    else()
        set(profile ${CMAKE_CXX_COMPILER_ID})
    endif()

    set(.vscode ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/${profile}/.vscode)
    Configure(
        ${.vscode}/launch.json
        ${CMAKE_SOURCE_DIR}/.vscode/launch.json
    )

    if(EXISTS ${.vscode}/tasks.json)
        Configure(
            ${.vscode}/tasks.json
            ${CMAKE_SOURCE_DIR}/.vscode/tasks.json
        )
    endif()

    # Configure clangd
    if(CMAKE_EXPORT_COMPILE_COMMANDS)
        get_filename_component(COMPILER_PATH ${CMAKE_CXX_COMPILER} DIRECTORY)
        if(EXISTS ${COMPILER_PATH}/clangd)
            AddQuotes(CLANGD ${COMPILER_PATH}/clangd)
        endif()
        UpdateJSONFile(
            ${CMAKE_SOURCE_DIR}/.vscode/settings.json
            clangd.path
            "${CLANGD}"
        )
    endif()
endfunction()

function(_DOTCMAKE_FINALIZE)
    # Generate env file for debuggin
    list(JOIN DEBUG_ENV \n DEBUG_ENV)
    file(GENERATE
        OUTPUT ${CMAKE_BINARY_DIR}/debug.env
        CONTENT "${DEBUG_ENV}"
    )
    # Configure IDEs
    if(DOTCMAKE_CONFIGURE_IDE)
        if(DEFINED ENV{VSCODE_CLI}) 
            ConfigureVScode()
        endif()
    endif()
    # clangd support
    if(CMAKE_EXPORT_COMPILE_COMMANDS)
        Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.clangd ${CMAKE_SOURCE_DIR}/.clangd)
     endif()
endfunction()

cmake_language(DEFER CALL _DOTCMAKE_FINALIZE)
