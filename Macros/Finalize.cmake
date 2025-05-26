function(ConfigureVScode)
    list(JOIN DEBUG_ARGS [[", "]] DEBUG_ARGS)

    if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
        set(profile Clang)
    else()
        set(profile ${CMAKE_CXX_COMPILER_ID})
    endif()

    Configure(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/${profile}/.vscode/launch.json
        ${CMAKE_SOURCE_DIR}/.vscode/launch.json
    )
    # Configure clangd
    if(CMAKE_EXPORT_COMPILE_COMMANDS)
        get_filename_component(COMPILER_PATH ${CMAKE_CXX_COMPILER} DIRECTORY)

        file(READ ${CMAKE_SOURCE_DIR}/.vscode/settings.json vscode_settings)
        if(vscode_settings)
            string(JSON elements LENGTH "${vscode_settings}")
            if(elements AND NOT elements EQUAL 0)
                string( JSON vscode_settings 
                        SET "${vscode_settings}"
                        "clangd.path"
                        "\"${COMPILER_PATH}/clangd\""
                )
                if(vscode_settings)
                    WriteIfChanged(${CMAKE_SOURCE_DIR}/.vscode/settings.json "${vscode_settings}")
                  endif()
            endif()
        endif()
    endif()
endfunction()

function(Finalize)
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

cmake_language(DEFER CALL Finalize)
