include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

# Global settings
set(CMAKE_CXX_STANDARD 23)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_CXX_SCAN_FOR_MODULES ON)

# Setup experimental import std;
if(NOT CMAKE_IN_TRY_COMPILE)
    set(CMAKE_CXX_MODULE_STD ON)

    if(CMAKE_MAJOR_VERSION LESS 4)
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
    else()
        if(CMAKE_MINOR_VERSION LESS 1 AND CMAKE_PATCH_VERSION LESS 3)
            set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "a9e1cf81-9932-4810-974b-6eccaf14e457")
        else()
            set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
        endif()
    endif()
endif()
