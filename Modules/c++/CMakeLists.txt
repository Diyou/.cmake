STATIC(.cmake PUBLIC
    FILE_SET module_files
    TYPE CXX_MODULES
    FILES
        Utils/Compiler.cxx
        Utils/Formatters.cxx
        Utils/GetFunctionName.cxx
        Utils/Platform.cxx
        Utils/Utils.ixx
)

if( CMAKE_CXX_MODULE_STD)
    target_compile_definitions(.cmake PUBLIC CMAKE_IMPORT_STD=1)
endif()

ALIAS(.cmake .cmake::Utils)
