set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(${PROJECT_NAME} STREQUAL CMAKE_TRY_COMPILE)
    return()
endif()

if(DEFINED DOTCMAKE_RUN_ONCE)
    return()
endif()
set(DOTCMAKE_RUN_ONCE ON)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../Packages
    ${CMAKE_CURRENT_LIST_DIR}/../Modules
)

# Options
option(DOTCMAKE_CONFIGURE_IDE "Configure IDE on Finalizing configuration" OFF)

# Configure toolchain
if(CMAKE_MAJOR_VERSION LESS 4)
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
else()
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "a9e1cf81-9932-4810-974b-6eccaf14e457")
endif()

set(CMAKE_CXX_SCAN_FOR_MODULES ON)
set(CMAKE_CXX_MODULE_STD ON)

# Include all macros
file(GLOB macros ${CMAKE_CURRENT_LIST_DIR}/../Macros/*.cmake)
foreach(macro ${macros})
    include(${macro})
endforeach()
