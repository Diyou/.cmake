include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/gradle/common.cmake)
RunOnlyOnce()

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
else()
    message(FATAL_ERROR "JAVA_HOME not set")
endif()
if(NOT EXISTS ${ANDROID_HOME})
    message(FATAL_ERROR "No Android SDK found")
endif()

# Retrieve the abi from the connected device
execute_process(COMMAND
    adb shell getprop ro.product.cpu.abi
OUTPUT_VARIABLE ABI_FILTER
ERROR_VARIABLE ABI_FILTER_ERROR
OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(ABI_FILTER_ERROR)
    # Fallback
    set(ABI_FILTER x86_64)
endif()

set(ANDROID_ABI ${ABI_FILTER})

# configure cmake for specific abi
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_ABI)

set(GRADLE_assemble assemble${CMAKE_BUILD_TYPE})
set(GRADLE_configureCMake configureCMake${CMAKE_BUILD_TYPE})
set(GRADLE_buildCMake buildCMake${CMAKE_BUILD_TYPE})

set(INTERNAL_BINARY_DIR_LINK "${CMAKE_BINARY_DIR}-${ANDROID_ABI}")
get_filename_component(INTERNAL_BINARY_DIR "${INTERNAL_BINARY_DIR_LINK}" REALPATH)

# sync with gradle
if(NOT EXISTS ${INTERNAL_BINARY_DIR_LINK})
    # trigger reconfiguration
    file(GLOB caches ${CMAKE_SOURCE_DIR}/Source/Android/app/.cxx/${CMAKE_BUILD_TYPE}/*/${ANDROID_ABI})
    foreach(cache ${caches})
        file(REMOVE_RECURSE "${cache}")
    endforeach()

    execute_process(COMMAND
        ${./}gradlew
            ${GRADLE_configureCMake}
        -Pandroid.injected.build.abi=${ABI_FILTER}
        --stacktrace
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Source/Android
        RESULT_VARIABLE result
    )

    if(${result})
        message(FATAL_ERROR "gradlew returned ${result}")
    endif()
endif()

# load internal gradle cache
load_cache(
    "${INTERNAL_BINARY_DIR}"
    EXCLUDE
        CMAKE_TOOLCHAIN_FILE
        CMAKE_PROJECT_TOP_LEVEL_INCLUDES
)

add_custom_target(assemble
    ${./}gradlew
        ${GRADLE_assemble}
    --Pandroid.injected.build.abi=${ABI_FILTER}
    --stacktrace    
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Source/Android
)
