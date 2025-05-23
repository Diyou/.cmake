STATIC(Utils PUBLIC
    FILE_SET module_files
    TYPE CXX_MODULES
    FILES
        Utils/Utils.c++
        Utils/Compiler.c++
)

add_library(cmake::Utils ALIAS Utils)
