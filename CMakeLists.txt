list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/Packages
    ${CMAKE_CURRENT_LIST_DIR}/Modules
)

# Automatically configures ide files (e.g .vscode/launch.json)
option(DOTCMAKE_CONFIGURE_IDE OFF)

include(GlobalVariables)
include(Macros)
include(Properties)
include(experimental)
