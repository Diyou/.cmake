STATIC(.cmake PUBLIC
    FILE_SET module_files
    TYPE CXX_MODULES
    FILES
        Utils/Utils.c++
        Utils/Compiler.c++
        Utils/Formatters.c++
        Utils/GetFunctionName.c++
)

add_library(.cmake::Utils ALIAS .cmake)
