# ./
if(WIN32)
    set(./ "")
else()
    set(./ ./)
endif()

# CMAKE_IN_TRY_COMPILE
if(${PROJECT_NAME} STREQUAL CMAKE_TRY_COMPILE)
    set(CMAKE_IN_TRY_COMPILE true)
else()
    set(CMAKE_IN_TRY_COMPILE false)
endif()
