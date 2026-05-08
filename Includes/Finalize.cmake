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
        # TODO GCC Fixup might be/become superfluous
        macro(GCC_Headers output)
            execute_process(COMMAND
                "${CMAKE_CXX_COMPILER}" -v -c -xc++ /dev/null
                ERROR_VARIABLE _OUTPUT
                RESULT_VARIABLE _RESULT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            if(_RESULT EQUAL 0)
                string(REGEX MATCH
                    "#include <...> search starts here:(.*)End of search list\."
                    _OUTPUT "${_OUTPUT}"
                )
                string(REGEX MATCHALL
                    "[^\n]+"
                    GCC_INCLUDES "${CMAKE_MATCH_1}"
                )
                set(${output} ${GCC_INCLUDES})
            endif() 
        endmacro()

        if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
            set(CLANGD_GCC_HEADERS "  Add:\n")
            set(CLANGD_GCC_HEADERS_PREFIX "    - -I")
            GCC_Headers(headers)
            foreach(header IN LISTS headers)
                string(STRIP "${header}" header)
                set(CLANGD_GCC_HEADERS
                    "${CLANGD_GCC_HEADERS}${CLANGD_GCC_HEADERS_PREFIX}${header}\n"
                )
            endforeach()
        endif()

        Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.clangd ${CMAKE_SOURCE_DIR}/.clangd)
     endif()
endfunction()

cmake_language(DEFER CALL _DOTCMAKE_FINALIZE)
