if(DEFINED DOTCMAKE_RUN_ONCE_android)
    return()
endif()
set(DOTCMAKE_RUN_ONCE_android ON)

set(ANDROID_PLATFORM android-35)
set(ANDROID_ABI arm64-v8a)

set(ANDROID_HOME "$ENV{ANDROID_HOME}")
if(ANDROID_HOME STREQUAL "")
    message(FATAL_ERROR "ENV{ANDROID_HOME} not set")
endif()

get_filename_component(ANDROID_HOME "${ANDROID_HOME}" ABSOLUTE)

if(NOT EXISTS ${ANDROID_HOME})
    message(FATAL_ERROR "${ANDROID_HOME} does not exist")
endif()

file(GLOB NDK_list RELATIVE "${ANDROID_HOME}/ndk" "${ANDROID_HOME}/ndk/*")
unset(NDKs)
foreach(NDK ${NDK_list})
    if(IS_DIRECTORY "${ANDROID_HOME}/ndk/${NDK}")
        list(APPEND NDKs "${NDK}")
    endif() 
endforeach()

list(SORT NDKs ORDER DESCENDING)
list(GET NDKs 0 NDK_VERSION)
if(NOT NDK_VERSION)
    message(FATAL_ERROR "No NDK Found")
endif()

include("${ANDROID_HOME}/ndk/${NDK_VERSION}/build/cmake/android.toolchain.cmake")
include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

if(${PROJECT_NAME} STREQUAL CMAKE_TRY_COMPILE)
    return()
endif()

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ ")
set(CMAKE_CXX_MODULE_STD OFF)
set(ANDROID_STL c++_shared)
