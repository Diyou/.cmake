include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)

# TODO disable until functional
set(CMAKE_CXX_MODULE_STD OFF)

# gradle requires java
find_package(Java 24 COMPONENTS Development)
if(NOT Java_FOUND)
    # TODO install local openjdk in .cache
    message(FATAL_ERROR "No Java Development(JDK) environment found")
endif()

# gradle requires ANDROID_HOME
if(DEFINED ENV{ANDROID_HOME})
    get_filename_component(ANDROID_HOME "$ENV{ANDROID_HOME}" ABSOLUTE)
else()
    message(FATAL_ERROR "JAVA_HOME not set")
endif()
if(NOT EXISTS ${ANDROID_HOME})
    message(FATAL_ERROR "No Android SDK found")
endif()

# configure cmake for specific abi
if(NOT DEFINED ANDROID_ABI)
    message(FATAL_ERROR "ANDROID_ABI not specified(e.g. arm64-v8a)")
endif()
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_ABI)

set(INTERNAL_BINARY_DIR_LINK "${CMAKE_BINARY_DIR}-${ANDROID_ABI}")
get_filename_component(INTERNAL_BINARY_DIR "${INTERNAL_BINARY_DIR_LINK}" REALPATH)

# sync with gradle
if(NOT EXISTS ${INTERNAL_BINARY_DIR_LINK})
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
        set(GRADLE_assemble assembleDebug)
        set(GRADLE_configureCMake configureCMakeDebug)
    else()
        set(GRADLE_assemble assembleRelease)
        set(GRADLE_configureCMake configureCMakeRelease)
    endif()

    execute_process(
        COMMAND ${./}gradlew ${GRADLE_configureCMake}[${ANDROID_ABI}]
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Source/Android
    )
endif()

# load internal gradle cache
load_cache(
    "${INTERNAL_BINARY_DIR}"
    EXCLUDE
        CMAKE_TOOLCHAIN_FILE
        CMAKE_PROJECT_TOP_LEVEL_INCLUDES
)
set_directory_properties(PROPERTIES ADDITIONAL_CLEAN_FILES
    "${INTERNAL_BINARY_DIR};${INTERNAL_BINARY_DIR_LINK}"
)
