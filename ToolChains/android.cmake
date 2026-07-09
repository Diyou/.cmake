include_guard(GLOBAL)
include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)

set(ANDROID_STL c++_shared)

if(CMAKE_IN_TRY_COMPILE)
    return()
endif()

macro(_COMMON_CONFIG)
    if(CMAKE_CXX_MODULE_STD)
        # needed for import std
        string(APPEND CMAKE_CXX_FLAGS " -D__BIONIC_CTYPE_INLINE=inline")
        string(REGEX REPLACE [[-D_FORTIFY_SOURCE(=[^ ]+)?]] "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

        set_property(SOURCE
            "${ANDROID_TOOLCHAIN_ROOT}/share/libc++/v1/std.cppm"
            "${ANDROID_TOOLCHAIN_ROOT}/share/libc++/v1/std.compat.cppm"
        PROPERTY
            COMPILE_FLAGS -Wno-reserved-module-identifier
        )
    endif()
endmacro()
cmake_language(DEFER CALL _COMMON_CONFIG)

# Coming from gradle
if(ANDROID)
    # Make the gradle files discoverable by the toplevel cmake project
    file(CREATE_LINK "${CMAKE_BINARY_DIR}"
        ${CMAKE_SOURCE_DIR}/build/${CMAKE_BUILD_TYPE}-android/${ANDROID_ABI}
    SYMBOLIC)
    return()
endif()

# gradle requires java
if(DEFINED ENV{JAVA_HOME})
    AppendPath(BEFORE $ENV{JAVA_HOME}/bin)
else()
    find_package(Java 17 COMPONENTS Development)
    if(NOT Java_FOUND)
        # TODO install **COMPATIBLE** local openjdk in .cache
        message(FATAL_ERROR "No Java Development(JDK) environment found")
    endif()
endif()

# gradle requires ANDROID_HOME
if(DEFINED ENV{ANDROID_HOME})
    get_filename_component(ANDROID_HOME "$ENV{ANDROID_HOME}" ABSOLUTE)
    set(ENV{ANDROID_HOME} "${ANDROID_HOME}")
else()
    message(FATAL_ERROR "JAVA_HOME not set")
endif()
if(NOT EXISTS ${ANDROID_HOME})
    message(FATAL_ERROR "No Android SDK found")
endif()

# Retrieve the abi from the connected device
execute_process(COMMAND adb shell getprop ro.product.cpu.abi
    OUTPUT_VARIABLE ANDROID_ABI
    ERROR_VARIABLE ANDROID_ABI_ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Fallback
if(ANDROID_ABI_ERROR)
    if(DOTCMAKE_HOST_IS_ARM)
        if(DOTCMAKE_HOST_IS_64BIT)
            set(ANDROID_ABI arm64-v8a)
        else()
            set(ANDROID_ABI armeabi-v7a)
        endif()
    else()
        if(DOTCMAKE_HOST_IS_64BIT)
            set(ANDROID_ABI x86_64)
        else()
            set(ANDROID_ABI x86)
        endif()
    endif()
endif()

# configure and build single abi apk
set(GRADLE_configureCMake configureCMake${CMAKE_BUILD_TYPE})
set(GRADLE_buildCMake buildCMake${CMAKE_BUILD_TYPE})
set(GRADLE_assemble assemble${CMAKE_BUILD_TYPE})
set(GRADLE_bundle bundle${CMAKE_BUILD_TYPE})

set(INTERNAL_CACHE_LINK "${CMAKE_BINARY_DIR}/${ANDROID_ABI}")
get_filename_component(INTERNAL_CACHE "${INTERNAL_CACHE_LINK}" REALPATH)

execute_process(COMMAND
    ${./}gradlew
        ${GRADLE_configureCMake}
    -Pandroid.injected.build.abi=${ANDROID_ABI}
    --stacktrace
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/Android
    RESULT_VARIABLE result
)

if(${result})
    message(FATAL_ERROR "gradlew returned ${result}")
endif()

# load internal gradle cache
if(NOT EXISTS "${INTERNAL_CACHE}")
    message(FATAL_ERROR "Failed to load")
endif()

load_cache("${INTERNAL_CACHE}")
include("${CMAKE_TOOLCHAIN_FILE}")

set_property(DIRECTORY PROPERTY ADDITIONAL_CLEAN_FILES
    "${INTERNAL_CACHE}"
)

# Utility targets
add_custom_target(assemble COMMAND
    ${./}gradlew
        ${GRADLE_assemble}
    -Pandroid.injected.build.abi=${ANDROID_ABI}
    --stacktrace
    COMMENT "gradlew ${GRADLE_assemble}"
    JOB_POOL console   
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/Android
)

add_custom_target(bundle COMMAND
    ${./}gradlew
        ${GRADLE_bundle}
    --stacktrace
    COMMENT "gradlew ${GRADLE_bundle}"
    JOB_POOL console   
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/Android
)
