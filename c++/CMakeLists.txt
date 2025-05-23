STATIC(DOTCMAKE_Utils PUBLIC
    FILE_SET module_files
    TYPE CXX_MODULES
    FILES
        Utils/Utils.c++)

add_library(DOTCMAKE::Utils ALIAS DOTCMAKE_Utils)
