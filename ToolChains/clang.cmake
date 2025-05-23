include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

set(ENV{CC} clang)
set(ENV{CXX} clang++)

# Enable libc++ on Linux
if(LINUX)
    set(CMAKE_CXX_FLAGS " -stdlib=libc++ -fexperimental-library " CACHE STRING "C++ compiler flags")
endif()
