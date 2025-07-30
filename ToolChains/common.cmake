include_guard(GLOBAL)

# Requirement
find_package(Git REQUIRED)

# Additional custom CMake modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../Modules
)

# Supported options
include(${CMAKE_CURRENT_LIST_DIR}/../Options.cmake)

# Includes in specific order
list(APPEND INCLUDES
    #[[Essential]]
    "Variables"
    "Macros"
    "Properties"
    #[[Features]]
    "Debug"
    "Finalize"
)

foreach(in ${INCLUDES})
    include("${CMAKE_CURRENT_LIST_DIR}/../Includes/${in}.cmake")
endforeach()

# Project.json.cmake needs to be included after the project() call
set(CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/../Includes/Project.json.cmake")

# Prevent Warning: Manually-specified variables were not used by the project:
if(CMAKE_TOOLCHAIN_FILE)
endif()
