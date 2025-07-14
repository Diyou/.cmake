get_filename_component(SCRIPT_NAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(DEFINED ${SCRIPT_NAME}_INCLUDED)
    return()
endif()
set(${SCRIPT_NAME}_INCLUDED ON)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../Modules
)

get_filename_component(PROJECT_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)

# Support options
include(${CMAKE_CURRENT_LIST_DIR}/../Options.cmake)

# Includes
file(GLOB includes ${CMAKE_CURRENT_LIST_DIR}/../Includes/*.cmake)
foreach(in ${includes})
    include(${in})
endforeach()
