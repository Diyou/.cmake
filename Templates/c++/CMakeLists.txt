cmake_minimum_required(VERSION 4.0.0)

set(DOTCMAKE_CONFIGURE_IDE ON)

project(HelloWorld CXX)

EXE(${PROJECT_NAME} Source/main.c++)

include(C++Utils)
target_link_libraries(${PROJECT_NAME} PRIVATE .cmake::Utils)
