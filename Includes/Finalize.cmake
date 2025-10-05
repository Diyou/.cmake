include_guard(GLOBAL)

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
            include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/IDEs/vscode/Config.cmake")
        elseif(DEFINED ENV{JETBRAINS_IDE})
            include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/IDEs/JetBrains/Config.cmake")
        endif()
    endif()
    # clangd support
    if(CMAKE_EXPORT_COMPILE_COMMANDS)
        Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.clangd ${CMAKE_SOURCE_DIR}/.clangd)
     endif()
endfunction()

cmake_language(DEFER CALL _DOTCMAKE_FINALIZE)
