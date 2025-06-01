STATIC(.cmake PUBLIC
    FILE_SET module_files
    TYPE CXX_MODULES
    FILES
        Utils/Utils.c++
        Utils/Compiler.c++
        Utils/Formatters.c++
        Utils/GetFunctionName.c++
        Utils/Platform.c++
)

if( CMAKE_CXX_MODULE_STD)
    target_compile_definitions(.cmake PUBLIC CMAKE_IMPORT_STD=1)
endif()

ALIAS(.cmake .cmake::Utils)
