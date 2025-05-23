set(DOTCMAKE_CACHE_DIR ${CMAKE_SOURCE_DIR}/.cache CACHE STRING "Cache Directory")

# Enable libc++ on Linux
if(USE_CLANG AND LINUX)
    set(CMAKE_CXX_FLAGS " -stdlib=libc++ -fexperimental-library " CACHE STRING "C++ compiler flags")
endif()
# Minumal requirements for c++20 modules
set(CMAKE_CXX_STANDARD 23 CACHE STRING "C++ standard")
set_property(CACHE CMAKE_CXX_STANDARD PROPERTY STRINGS 23 26)
option(CMAKE_CXX_SCAN_FOR_MODULES "Enables c++20 module scanning" ON)
option(CMAKE_CXX_MODULE_STD "Enables import std;" ON)
option(CMAKE_CXX_EXTENSIONS "Enable compiler-specific extensions" ON)
