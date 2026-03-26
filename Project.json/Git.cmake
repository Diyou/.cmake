# Namespace
function(ParseGITDependency)
    GetJSON(JSON url url)
    GetJSON(JSON tag tag)

    if(NOT tag)
        message(WARNING [[Missing property "tag"]])
        FAIL()
        return()
    endif()
    if(NOT tag)
        message(WARNING [[Missing property "tag"]])
        FAIL()
        return()
    endif()
    
    GetJSON(JSON shallow shallow)
    if(shallow STREQUAL shallow-NOTFOUND)
        set(shallow ON)
    endif()

    if(NOT EXISTS "${DEPENDENCY_DIR}")
        Clone()
        Checkout()
        ParseGITModules()
        return()
    endif()

    IsTopLevel(is)
    if(NOT is)
        Uninstall()
        Clone()
        Checkout()
        ParseGITModules()
        return()
    endif()

    # Validate reconfiguration
    ParseShallow()

    IsClone(is)
    if(NOT is)
        SetRemote()
        Checkout()
    endif()

    GitTag("${DEPENDENCY_DIR}" old_tag)
    if(NOT tag MATCHES "${old_tag}")
        Checkout()
    endif()
    
    ParseGITModules()
endfunction()

## Helpers ######################################################

macro(ParseGITModules)
    GetJSON(JSON submodules submodules)
    if(submodules)
        GetJSONArray(submodules submodules)
        ListSubModules(inited_submodules)
        foreach(submodule ${submodules})
            execute_process(COMMAND "${GIT_EXECUTABLE}"
                config --file .gitmodules --get-regexp "^submodule\\..*${submodule}.*\\.path$"
                WORKING_DIRECTORY "${DEPENDENCY_DIR}"
                OUTPUT_VARIABLE out
                RESULT_VARIABLE res
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            string(REPLACE "\n" ";" candidates "${out}")
            foreach(candidate ${candidates})
                string(REGEX MATCH "path[ \t]+(.+)" _match "${candidate}")
                set(submodule "${CMAKE_MATCH_1}")
                list(FIND inited_submodules "${submodule}" index)
                if(index EQUAL -1)   
                    message("Adding '${submodule}'")             
                    execute_process(COMMAND "${GIT_EXECUTABLE}"
                        submodule update --init
                        --depth=2 --no-single-branch
                        "${submodule}"
                        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
                        OUTPUT_QUIET
                        RESULT_VARIABLE res
                        ERROR_VARIABLE err
                    )
                    if(error)
                        message(WARNING "${err}")
                    endif()
                endif()
            endforeach()
        endforeach()
    endif()
endmacro()

macro(ParseShallow)
    IsShallow(is)

    # XOR
    if( (${is} AND NOT ${shallow})
    OR  (NOT ${is} AND ${shallow}))
        if(shallow)
            MakeShallow()
        else()
            UnShallow()
        endif()
    endif()
endmacro()

### Clone
macro(IsClone output)
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        remote get-url origin
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_VARIABLE out
        RESULT_VARIABLE res
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(out MATCHES "${url}")
        set(${output} TRUE)
    else()
        set(${output} FALSE)
    endif()
endmacro()

macro(SetRemote)
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        remote set-url origin "${url}"
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endmacro()

macro(Clone)
    message("Cloning\t'${url}'")

    unset(shallow_args)
    if(shallow)
        set(shallow_args --depth=2 --no-single-branch --shallow-submodules)
    endif()

    execute_process(COMMAND "${GIT_EXECUTABLE}"
        clone -c advice.detachedHead=false --no-checkout
        ${shallow_args}
        ${url} ${DEPENDENCY}
        WORKING_DIRECTORY "${DEPENDENCY_ROOT}"
        OUTPUT_QUIET
        RESULT_VARIABLE res
        ERROR_VARIABLE err
    )
    if(error)
        message(WARNING "${err}")
    endif()
endmacro()

macro(Checkout)
    message("Checking\t'${DEPENDENCY}' out at '${tag}'")
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        checkout --recurse-submodules ${tag}
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_QUIET
        RESULT_VARIABLE res
        ERROR_VARIABLE err
    )
    if(error)
        message(WARNING "${err}")
    else()
        PREPARE_PATCH()
    endif()
endmacro()

### Shallow
macro(IsShallow output)
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        rev-parse --is-shallow-repository
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_VARIABLE out
        RESULT_VARIABLE res
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    if(res EQUAL 0 AND out)
        set(${output} TRUE)
    else()
        set(${output} FALSE)
    endif()
endmacro()

macro(MakeShallow)
    message("Removing commit history (shallow)")

    set(git_tmp .git_tmp)
    set(git_backup .git_backup)

    # Create temporary shallow replacement
    set(shallow_args --depth=2 --no-single-branch --shallow-submodules)
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        clone -c advice.detachedHead=false --no-checkout
        --branch ${tag}
        ${shallow_args}
        ${url} ${git_tmp}
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_QUIET
        RESULT_VARIABLE res
        ERROR_VARIABLE err
    )
    if(NOT res EQUAL 0)
        file(REMOVE_RECURSE "${DEPENDENCY_DIR}/${git_tmp}")
    else()
        # migrate modules and config
        if(EXISTS "${DEPENDENCY_DIR}/.git/modules")
            file(COPY   "${DEPENDENCY_DIR}/.git/modules"
            DESTINATION "${DEPENDENCY_DIR}/${git_tmp}/.git")
            
            file(READ "${DEPENDENCY_DIR}/.git/config" _config)
            string(REGEX MATCHALL [[\[submodule "[^"]+"\][^\[]*]] _config_submodules "${_config}")
            if(_config_submodules)
                list(JOIN _config_submodules "" _config_submodules)
                file(APPEND
                    "${DEPENDENCY_DIR}/${git_tmp}/.git/config"
                    "\n${_config_submodules}\n"
                )
            endif()
        endif()

        # backup
        file(RENAME
            "${DEPENDENCY_DIR}/.git"
            "${DEPENDENCY_DIR}/${git_backup}"
            RESULT res
        )
        if(NOT res EQUAL 0)
            message(WARNING "${res}")
        else()
            # swap
            file(RENAME
                "${DEPENDENCY_DIR}/${git_tmp}/.git"
                "${DEPENDENCY_DIR}/.git"
                RESULT res
            )
            if(res EQUAL 0)
                # relink
                execute_process(COMMAND "${GIT_EXECUTABLE}"
                    reset --mixed ${tag}
                    WORKING_DIRECTORY "${DEPENDENCY_DIR}"
                    OUTPUT_QUIET
                    ERROR_QUIET
                )
                execute_process(COMMAND "${GIT_EXECUTABLE}"
                    submodule absorbgitdirs
                    WORKING_DIRECTORY ${DEPENDENCY_DIR}
                    OUTPUT_QUIET
                    ERROR_QUIET
                )
                execute_process(COMMAND
                    ${CMAKE_COMMAND} -E rm -rf
                    "${DEPENDENCY_DIR}/${git_backup}"
                    "${DEPENDENCY_DIR}/${git_tmp}"
                    RESULT_VARIABLE res
                )
            endif()
        endif()
    endif()
endmacro()

macro(UnShallow)
    message("Fetching commit history (unshallow)")
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        fetch --unshallow
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        RESULT_VARIABLE res
    )
    Checkout()
endmacro()

### SubModules
macro(ListSubModules submodules)
    unset(${submodules})
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        submodule foreach --quiet "echo $sm_path"    
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_VARIABLE out
        RESULT_VARIABLE res
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(res EQUAL 0)
        string(REPLACE "\n" ";" ${submodules} "${out}")
    endif()
endmacro()

### Other
macro(IsTopLevel output)
    execute_process(COMMAND "${GIT_EXECUTABLE}"
        rev-parse --show-toplevel
        WORKING_DIRECTORY "${DEPENDENCY_DIR}"
        OUTPUT_VARIABLE out
        RESULT_VARIABLE res
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(res EQUAL 0
    AND out STREQUAL DEPENDENCY_DIR)
        set(${output} TRUE)
    else()
        set(${output} FALSE)
    endif()
endmacro()
