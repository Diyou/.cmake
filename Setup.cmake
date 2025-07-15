# This file is supposed to be run on the command-line
# to install Templates
# As a shorthand use the shell/bash scripts like:
# .cmake/setup c++
cmake_minimum_required(VERSION 3.29)

option(TEMPLATE "A subdirectory of Templates/ to copy contents from")

set(ERROR_NO_ARG    1)
set(ERROR_WRONG_ARG 2)

set(TEMPLATES_DIR "${CMAKE_CURRENT_LIST_DIR}/Templates")

function(HELP)
    message("Usage: ${CMAKE_COMMAND} -D TEMPLATE=<template> -P .cmake/Setup.cmake")
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

if(NOT TEMPLATE)
    message(WARNING [[No template specified]])
    HELP()
    cmake_language(EXIT ${ERROR_NO_ARG})
endif()

set(TEMPLATE_DIR "${TEMPLATES_DIR}/${TEMPLATE}")

if(NOT EXISTS "${TEMPLATE_DIR}")
    message(WARNING "Template '${TEMPLATE}' does not exist")
    LIST_TEMPLATES()
    HELP()
    cmake_language(EXIT ${ERROR_WRONG_ARG})
endif()

message("template: ${TEMPLATE_DIR}")
