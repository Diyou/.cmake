# This file is supposed to be run on the command-line
# to install Templates
# As a shorthand use the shell/bash scripts like:
# .cmake/setup c++
cmake_minimum_required(VERSION 3.29)

# Filter args beginning with CWD
unset(ARGS)
set(ADD_ARGS OFF)
file(REAL_PATH "${CMAKE_CURRENT_BINARY_DIR}" CWD)
math(EXPR LAST_ARG "${CMAKE_ARGC} - 1")
foreach(i RANGE 0 ${LAST_ARG})
    if(NOT ADD_ARGS AND EXISTS "${CMAKE_ARGV${i}}")
        file(REAL_PATH "${CMAKE_ARGV${i}}" check_path)
        if(CWD STREQUAL check_path)
            set(ADD_ARGS ON)
        endif()
    elseif(ADD_ARGS)
        list(APPEND ARGS "${CMAKE_ARGV${i}}")
    endif()
endforeach()
list(LENGTH ARGS ARGC)

# Error codes
set(ERROR_NO_ARG    1)
set(ERROR_WRONG_ARG 2)

# Templates location
set(TEMPLATES_DIR "${CMAKE_CURRENT_LIST_DIR}/Templates")

# Helpers
function(HELP)
    message("Usage: .cache/setup <template>...")
endfunction()

function(LIST_TEMPLATES)
    file(GLOB items RELATIVE ${TEMPLATES_DIR} ${TEMPLATES_DIR}/*)
    message("Available Templates:")
    list(APPEND CMAKE_MESSAGE_INDENT " ")
    foreach(item ${items})
        if(IS_DIRECTORY "${TEMPLATES_DIR}/${item}")
            message("${item}")
        endif()
    endforeach()
    list(POP_BACK CMAKE_MESSAGE_INDENT)
endfunction()

# No arguments
if(ARGC EQUAL 0)
    message(WARNING [[No template specified]])
    HELP()
    cmake_language(EXIT ${ERROR_NO_ARG})
endif()

# Check if templates are available
set(HAS_TEMPLATES YES)
foreach(template ${ARGS})
    if(NOT EXISTS "${TEMPLATES_DIR}/${template}")
        message(WARNING "Template '${template}' does not exist")
        set(HAS_TEMPLATES NO)
    endif()
endforeach()
if(NOT HAS_TEMPLATES)
    HELP()
    message("")
    LIST_TEMPLATES()
    cmake_language(EXIT ${ERROR_WRONG_ARG})
endif()

function(CopyDirectory dir)

    cmake_parse_arguments(PARSE_ARGV 1 ARG "" "MAXDEPTH" "")

    if(NOT IS_DIRECTORY "${dir}")
        message(FATAL_ERROR "cmake_tree: '${dir}' is not a directory")
    endif()

    # Normalize path and remove trailing slash
    get_filename_component(dir "${dir}" ABSOLUTE)
    string(REGEX REPLACE "/+$" "" dir "${dir}")

    # Default max depth = very large (practically unlimited)
    if(NOT ARG_MAXDEPTH)
        set(ARG_MAXDEPTH 999)
    endif()

    # ─── Helper: recursive tree printer ──────────────────────────────────────
    function(_cmake_tree_print current_path prefix depth)

        if(depth GREATER_EQUAL ARG_MAXDEPTH)
            message(STATUS "${prefix}└─ … (max depth reached)")
            return()
        endif()

        file(GLOB children RELATIVE "${current_path}" "${current_path}/*")
        list(SORT children)

        # Separate directories and files
        set(dirs "")
        set(files "")
        foreach(child IN LISTS children)
            if(IS_DIRECTORY "${current_path}/${child}")
                list(APPEND dirs "${child}")
            else()
                list(APPEND files "${child}")
            endif()
        endforeach()

        # Combine: dirs first, then files (both already sorted)
        set(sorted_children ${dirs} ${files})
        list(LENGTH sorted_children len)

        math(EXPR last_index "${len} - 1")

        foreach(i RANGE ${last_index})
            list(GET sorted_children ${i} item)
            set(fullpath "${current_path}/${item}")

            # Decide which connector to use
            if(i EQUAL last_index)
                set(connector "└─ ")
                set(next_prefix "${prefix}   ")
            else()
                set(connector "├─ ")
                set(next_prefix "${prefix}│  ")
            endif()

            # Print current item
            if(IS_DIRECTORY "${fullpath}")
                message(STATUS "${prefix}${connector}${item}/")
                _cmake_tree_print("${fullpath}" "${next_prefix}" ${depth}+1)
            else()
                # Copy if destination doesn't exist
                file(RELATIVE_PATH rel_path "${dir}" "${fullpath}")
                set(source_file "${current_path}/${item}")
                set(destination_file "${CWD}/${rel_path}")
                if(EXISTS "${destination_file}")
                    set(suffix ✕)
                else()
                    set(suffix ✓)
                    configure_file("${source_file}" "${destination_file}" COPYONLY)
                endif()
                message(STATUS "${prefix}${connector}${item} ${suffix}")
            endif()
        endforeach()

    endfunction()

    # ─── Main call ────────────────────────────────────────────────────────────
    get_filename_component(basename "${dir}" NAME)
    message(STATUS "${basename}/")
    _cmake_tree_print("${dir}" "" 1)

endfunction()

# Finally copy all templates
foreach(template ${ARGS})
    message("Copying ${TEMPLATES_DIR}/${template} -> ${CWD}:")
    CopyDirectory("${TEMPLATES_DIR}/${template}")
endforeach()
