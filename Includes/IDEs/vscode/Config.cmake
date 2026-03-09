if(WIN32)
    find_program(VSCODE Code.exe)
else()
    find_program(VSCODE code)
endif()

execute_process(COMMAND
    "${VSCODE}" --list-extensions --show-versions
    OUTPUT_VARIABLE VSCODE_EXTENSIONS
    RESULT_VARIABLE _RESULT
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(_RESULT EQUAL 0)
    string(REPLACE "\n" ";" VSCODE_EXTENSIONS "${VSCODE_EXTENSIONS}")
    # Check if clangd extension is available
    foreach(extension IN LISTS VSCODE_EXTENSIONS)
        if(extension MATCHES [[(.+)\.vscode-clangd@([^ ]+)]])
            set(VSCODE_CLANGD "${CMAKE_MATCH_2}")
            break()
        endif()
    endforeach()
endif()

list(JOIN DEBUG_ARGS [[", "]] DEBUG_ARGS)

if(ANDROID)
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
if( CMAKE_EXPORT_COMPILE_COMMANDS
AND VSCODE_CLANGD)
    get_filename_component(COMPILER_PATH "${CMAKE_CXX_COMPILER}" DIRECTORY)
    if(EXISTS ${COMPILER_PATH}/clangd)
        AddQuotes(CLANGD ${COMPILER_PATH}/clangd)
    endif()
    UpdateJSONFile(
        ${CMAKE_SOURCE_DIR}/.vscode/settings.json
        clangd.path
        "${CLANGD}"
    )
endif()
