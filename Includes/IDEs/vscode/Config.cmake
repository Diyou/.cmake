list(JOIN DEBUG_ARGS [[", "]] DEBUG_ARGS)

if(CMAKE_SYSTEM_NAME STREQUAL Android)
    set(profile Android)
elseif(EMSCRIPTEN)
    set(profile Emscripten)
elseif(CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set(profile Clang)
else()
    set(profile ${CMAKE_CXX_COMPILER_ID})
endif()

set(.vscode "${CMAKE_CURRENT_LIST_DIR}/${profile}/.vscode")
Configure(
    ${.vscode}/launch.json
    ${CMAKE_SOURCE_DIR}/.vscode/launch.json
)

if(EXISTS ${.vscode}/tasks.json)
    Configure(
        ${.vscode}/tasks.json
        ${CMAKE_SOURCE_DIR}/.vscode/tasks.json
    )
endif()

# Configure clangd
if(CMAKE_EXPORT_COMPILE_COMMANDS)
    get_filename_component(COMPILER_PATH ${CMAKE_CXX_COMPILER} DIRECTORY)
    if(EXISTS ${COMPILER_PATH}/clangd)
        AddQuotes(CLANGD ${COMPILER_PATH}/clangd)
    endif()
    UpdateJSONFile(
        ${CMAKE_SOURCE_DIR}/.vscode/settings.json
        clangd.path
        "${CLANGD}"
    )
endif()
