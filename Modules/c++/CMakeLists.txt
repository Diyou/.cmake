STATIC(.cmake PUBLIC
    FILE_SET module_files
    TYPE CXX_MODULES
    FILES
        Utils/Utils.c++
        Utils/Compiler.c++
        Utils/Formatters.c++
        Utils/GetFunctionName.c++
)

if(TARGET __CMAKE::CXX23 OR TARGET __CMAKE::CXX26)
    target_compile_definitions(.cmake PUBLIC CMAKE_IMPORT_STD=1)
endif()

add_library(.cmake::Utils ALIAS .cmake)
