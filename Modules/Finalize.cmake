# This file is included as part of the toolchain file (ToolChains/common.cmake)

macro(ConfigureVScode)
if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/lldb/.vscode/launch.json ${CMAKE_SOURCE_DIR}/.vscode/launch.json)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL GNU)
    Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gdb/.vscode/launch.json ${CMAKE_SOURCE_DIR}/.vscode/launch.json)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL MSVC)
    Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/vsdbg/.vscode/launch.json ${CMAKE_SOURCE_DIR}/.vscode/launch.json)
endif() 
endmacro()

macro(CopyClangD)
    Configure(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.clangd ${CMAKE_SOURCE_DIR}/.clangd)
endmacro()

function(Finalize)
    if(DOTCMAKE_CONFIGURE_IDE AND $ENV{VSCODE_CLI})
        ConfigureVScode()
    endif()
    # clangd support
    if(CMAKE_EXPORT_COMPILE_COMMANDS)
        CopyClangD()
    endif()
endfunction()

cmake_language(DEFER CALL Finalize)
