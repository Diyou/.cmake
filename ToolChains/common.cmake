# Guard against repeated inclusions
get_filename_component(SCRIPT_NAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(DEFINED ${SCRIPT_NAME}_INCLUDED)
    return()
endif()
set(${SCRIPT_NAME}_INCLUDED ON)

# Additional custom CMake modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../Modules
)

# Supported options
include(${CMAKE_CURRENT_LIST_DIR}/../Options.cmake)

# Includes in specific order
unset(INCLUDES)
list(APPEND INCLUDES
    #[[Essential]]
    "Variables"
    "Macros"
    "Properties"
    #[[Features]]
    "Project.json"
    "Debug"
    "Finalize"
)
foreach(in ${INCLUDES})
    include("${CMAKE_CURRENT_LIST_DIR}/../Includes/${in}.cmake")
endforeach()
