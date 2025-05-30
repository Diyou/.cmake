get_filename_component(SCRIPT_NAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(DEFINED ${SCRIPT_NAME}_INCLUDED)
    return()
endif()
set(${SCRIPT_NAME}_INCLUDED ON)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../Packages
    ${CMAKE_CURRENT_LIST_DIR}/../Modules
)

# Support options
include(${CMAKE_CURRENT_LIST_DIR}/../Options.cmake)

# Includes
file(GLOB includes ${CMAKE_CURRENT_LIST_DIR}/../Includes/*.cmake)
foreach(in ${includes})
    include(${in})
endforeach()
