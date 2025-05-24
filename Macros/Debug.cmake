# This file facilitates a debug environment that works together with Finalize

set(DEBUG_ARGS CACHE INTERNAL "")
set(DEBUG_ENV  CACHE INTERNAL "")

macro(ADD_DEBUG_ARGS)
    list(APPEND DEBUG_ARGS ${ARGN})
    set(DEBUG_ARGS ${DEBUG_ARGS} CACHE INTERNAL "") 
endmacro()

function(READ_DEBUG_ENV_VAR var_in name_out value_out)
    string(FIND ${var_in} = POS)
    math(EXPR offset "${POS} + 1")
    string(SUBSTRING ${var_in} 0 ${POS} name)
    string(SUBSTRING ${var_in} ${offset} -1 value)
    set(${name_out} ${name} PARENT_SCOPE)
    set(${value_out} ${value} PARENT_SCOPE)
endfunction()

function(ADD_DEBUG_ENV_VAR var)
    string(FIND ${var} = POS)
    if(POS EQUAL -1)
        message(WARNING "[Syntax Error] '${var}' is not a valid environment variable")
    else()
        list(APPEND DEBUG_ENV ${var})
        set(DEBUG_ENV ${DEBUG_ENV} CACHE INTERNAL "")
    endif()
endfunction()

macro(ADD_DEBUG_ENV_VARS)
    foreach(var ${ARGN})
        ADD_DEBUG_ENV_VAR(${var})
    endforeach()
endmacro()
