include(${CMAKE_CURRENT_LIST_DIR}/default.cmake)

set(ENV{CC} clang)
set(ENV{CXX} clang++)

# Enable libc++ on Linux
if(LINUX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ ")
endif()
