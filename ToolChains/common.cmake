include_guard(GLOBAL)

# Global settings
set(CMAKE_CXX_STANDARD 23)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_CXX_SCAN_FOR_MODULES ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/dist") # Executables
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/dist") # Dynamic Libraries
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")  # Static Libraries

#Setup .cmake functions
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
    list(APPEND CMAKE_PROJECT_INCLUDE
        "${CMAKE_CURRENT_LIST_DIR}/../Project.json/Project.cmake"
    )
endif()

IncludeQueued()

endif(PROJECT_IS_TOP_LEVEL)

# Setup experimental import std;
if(NOT CMAKE_IN_TRY_COMPILE)
    set(CMAKE_CXX_MODULE_STD ON)

    if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.3.0)
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            451f2fe2-a8a2-47c3-bc32-94786d8fc91b
        )
    else()
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            d0edc3af-4c50-42ea-a356-e2862fe7a444
        )
    endif()
endif()

# Prevent Warning: Manually-specified variables were not used by the project:
if(CMAKE_TOOLCHAIN_FILE)
endif()
