# This file facilitates a debug environment that works together with Finalize

set(DEBUG_ARGS CACHE INTERNAL "")
set(DEBUG_ENV  CACHE INTERNAL "")

macro(ADD_DEBUG_ARGS)
    list(APPEND DEBUG_ARGS ${ARGN})
    set(DEBUG_ARGS ${DEBUG_ARGS} CACHE INTERNAL "") 
endmacro()

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
