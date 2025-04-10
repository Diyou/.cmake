list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/Packages
)
include(Macros)
include(experimental)

if(USE_CLANG AND LINUX)
    string(APPEND CMAKE_CXX_FLAGS " -stdlib=libc++ ")
    add_compile_options(-fexperimental-library)
endif()

# clangd support
if(CMAKE_EXPORT_COMPILE_COMMANDS)
Configure(${CMAKE_CURRENT_LIST_DIR}/.clangd ${CMAKE_CURRENT_SOURCE_DIR}/.clangd)
endif()