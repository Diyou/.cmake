file(CREATE_LINK
    ${CMAKE_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/build/${CMAKE_BUILD_TYPE}-android-${ANDROID_ABI}
SYMBOLIC)

include(${CMAKE_CURRENT_LIST_DIR}/../clang.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)
