list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/Packages
)
include(experimental)

if(USE_CLANG AND LINUX)
    string(APPEND CMAKE_CXX_FLAGS " -stdlib=libc++ ")
    add_compile_options(-fexperimental-library)
endif()