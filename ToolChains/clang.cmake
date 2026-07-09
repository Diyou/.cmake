include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

set(ENV{CC} clang)
set(ENV{CXX} clang++)

# Force libc++
if(LINUX)
    string(APPEND CMAKE_CXX_FLAGS " -stdlib=libc++")
endif()
