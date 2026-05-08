if(WIN32)
    find_program(VSCODE Code.exe REQUIRED)
else()
    find_program(VSCODE code REQUIRED)
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

# Debugging
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

# Launch configs
set(.vscode "${CMAKE_CURRENT_LIST_DIR}/${profile}/.vscode")
Configure(
    ${.vscode}/launch.json
    ${CMAKE_SOURCE_DIR}/.vscode/launch.json
)

# Tasks
if(EXISTS ${.vscode}/tasks.json)
    Configure(
        ${.vscode}/tasks.json
        ${CMAKE_SOURCE_DIR}/.vscode/tasks.json
    )
endif()

# settings.json
set(settings.json "${PROJECT_ROOT}/.vscode/settings.json")
if(NOT EXISTS "${settings.json}")
    set(JSON {})
else()
    file(READ "${settings.json}" JSON)
endif()
ValidJSON(JSON valid)

if(valid)
    # CMake Settings
    set(UseCMAKEPresets always)
    AddQuotes(UseCMAKEPresets)
    SetJSON(JSON cmake.useCMakePresets ${UseCMAKEPresets})

    # Cpp settings
    SetJSON(JSON C_Cpp.autoAddFileAssociations false)

    # Clangd settings
    if(VSCODE_CLANGD)
        set(IntelliSenseEngine disabled)
        AddQuotes(IntelliSenseEngine)

        SetJSON(JSON clangd.arguments
            [[ [
            "--header-insertion=never",
            "--clang-tidy"
            ] ]]
        )
        
        unset(clangd)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            execute_process(COMMAND
                "${CMAKE_CXX_COMPILER}"
                --print-prog-name=clangd
                OUTPUT_VARIABLE out
                ERROR_QUIET
                RESULT_VARIABLE res
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(res EQUAL 0)
                set(clangd "${out}")
            endif()
        else()
            find_program(clangd clangd)
        endif()
    else()
        set(IntelliSenseEngine default)
        AddQuotes(IntelliSenseEngine)

        SetJSON(JSON clangd.arguments "")
    endif()
    SetJSON(JSON C_Cpp.intelliSenseEngine "${IntelliSenseEngine}")
    if(clangd)
        AddQuotes(clangd)
        SetJSON(JSON clangd.path "${clangd}")
    else()
        SetJSON(JSON clangd.path "")
    endif()

    # Convenience settings
    SetJSON(JSON files.insertFinalNewline true)
    SetJSON(JSON files.trimFinalNewlines true)
    SetJSON(JSON output.smartScroll.enabled false)
endif()

ValidJSON(JSON valid)
if(valid)
    WriteIfChanged("${settings.json}" "${JSON}")
else()
    message(WARNING "Invalid json for settings.json:\n${JSON}")
endif()
