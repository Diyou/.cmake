include_guard(GLOBAL)

if(PROJECT_IS_TOP_LEVEL)

# Requirement
find_package(Git REQUIRED)

# Additional custom CMake modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../Modules
)

# Supported options
include(${CMAKE_CURRENT_LIST_DIR}/../Options.cmake)

# Includes in specific order
macro(IncludeQueued)
    foreach(in ${INCLUDES})
        include("${CMAKE_CURRENT_LIST_DIR}/../Includes/${in}.cmake")
    endforeach()
    unset(INCLUDES)
endmacro()

list(APPEND INCLUDES
    #[[Essential]]
    "Variables"
    "Macros"
    "Properties"
)
IncludeQueued()

if(NOT ${CMAKE_IN_TRY_COMPILE})
    list(APPEND INCLUDES
        #[[Features]]
        "Debug"
        "Finalize"
    )
    # Project.json.cmake needs to be included after the project() call
    set(CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/../Includes/Project.json.cmake")
endif()

IncludeQueued()

endif(PROJECT_IS_TOP_LEVEL)

# Prevent Warning: Manually-specified variables were not used by the project:
if(CMAKE_TOOLCHAIN_FILE)
endif()
