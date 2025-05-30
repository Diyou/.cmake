if(${PROJECT_NAME} STREQUAL CMAKE_TRY_COMPILE)
    return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

find_package(Java 24 COMPONENTS Development)
if(NOT Java_FOUND)
    # TODO install local openjdk in .cache
    message(FATAL_ERROR "No Java Development(JDK) environment found")
endif()

if(DEFINED ENV{ANDROID_HOME})
    get_filename_component(ANDROID_HOME "$ENV{ANDROID_HOME}" ABSOLUTE)
else()
    message(FATAL_ERROR "JAVA_HOME not set")
endif()
if(NOT EXISTS ${ANDROID_HOME})
    message(FATAL_ERROR "No Android SDK found")
endif()

if(NOT DEFINED ANDROID_ABI)
    message(FATAL_ERROR "ANDROID_ABI not specified(e.g. arm64-v8a)")
endif()
set(ANDROID_ABI ${ANDROID_ABI} CACHE INTERNAL "")

if(DEFINED DOTCMAKE_RUN_ONCE)
    return()
endif()
set(DOTCMAKE_RUN_ONCE ON)

set(INTERNAL_BINARY_DIR_LINK "${CMAKE_BINARY_DIR}-${ANDROID_ABI}")
get_filename_component(INTERNAL_BINARY_DIR "${INTERNAL_BINARY_DIR_LINK}" REALPATH)

macro(LoadInternalCache)
    load_cache(
        "${INTERNAL_BINARY_DIR}"
        EXCLUDE
            CMAKE_TOOLCHAIN_FILE
            CMAKE_PROJECT_TOP_LEVEL_INCLUDES
    )
    set_directory_properties(PROPERTIES ADDITIONAL_CLEAN_FILES
        "${INTERNAL_BINARY_DIR};${INTERNAL_BINARY_DIR_LINK}"
    )
    set(CMAKE_BINARY_DIR "${INTERNAL_BINARY_DIR}")
endmacro()

if(EXISTS ${INTERNAL_BINARY_DIR})
    LoadInternalCache()
    return()
endif()

if(WIN32)
    set(./ "")
else()
    set(./ ./)
endif()

if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(GRADLE_assemble assembleDebug)
else()
    set(GRADLE_assemble assembleRelease)
endif()

if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(GRADLE_configureCMake configureCMakeDebug)
else()
    set(GRADLE_configureCMake configureCMakeRelease)
endif()

execute_process(
    COMMAND ${./}${gradlew} ${GRADLE_configureCMake}[${ANDROID_ABI}]
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Source/Android
)

LoadInternalCache()
