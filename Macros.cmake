# macros.cmake - Diyou.Lib
# 
# Copyright (c) 2024 Diyou
# All rights reserved.
# 
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

set(CACHE_DIR_RELATIVE .cache)
set(CACHE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${CACHE_DIR_RELATIVE})

find_package(Git REQUIRED)
include(FetchContent)

function(_add_sources target)
set(options)
set(oneValueArgs)
set(multiValueArgs PRIVATE PUBLIC INTERFACE)
cmake_parse_arguments(_ "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

target_sources(${target}
  PUBLIC ${__PUBLIC}${__UNPARSED_ARGUMENTS}
  PRIVATE ${__PRIVATE}
  INTERFACE ${__INTERFACE}
)
endfunction()


# Shorthand for add_executable(name)
macro(EXE name)
  add_executable(${name} WIN32)
  _add_sources(${name} ${ARGN})
endmacro()

# Shorthand for add_library(name)
macro(LIB name)
  add_library(${name})
  _add_sources(${name} ${ARGN})
endmacro()

# Shorthand for add_library(name SHARED)
macro(DLL name)
  add_library(${name} SHARED)
  _add_sources(${name} ${ARGN})
endmacro()

# Shorthand for add_library(name STATIC)
macro(STATIC name)
  add_library(${name} STATIC)
  _add_sources(${name} ${ARGN})
endmacro()

# Shorthand for add_library(name INTERFACE)
macro(INTERFACE name)
  add_library(${name} INTERFACE)
  _add_sources(${name} ${ARGN})
endmacro()

# Shorthand for add_library(name MODULE)
macro(MODULE name)
  add_library(${name} MODULE)
  _add_sources(${name} ${ARGN})
endmacro()


function(DeclareDependency NAME URL TAG)
  set(options)
  set(oneValueArgs)
  set(multiValueArgs PATCH SUBMODULES PRELOAD)
  cmake_parse_arguments(_ "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  Message(STATUS "Adding Dependency: ${NAME}")

  # This prevents add_subdirectory
  # and alows to add dependencies beforehand
  if(__PRELOAD)
    set(SOURCE_SUBDIR ${CACHE_DIR_RELATIVE}/${NAME}Preload)
    set(_LIST ${FetchList_NeedsPreload})
    list(APPEND _LIST ${NAME})
    set(FetchList_NeedsPreload ${_LIST} PARENT_SCOPE)
    set(FetchList_NeedsPreload_${NAME} ${__PRELOAD} PARENT_SCOPE)
  endif()

  FetchContent_Declare(${NAME}
    GIT_REPOSITORY    ${URL}
    GIT_TAG           ${TAG}
    GIT_SHALLOW       TRUE
    GIT_SUBMODULES    "${__SUBMODULES}"
    GIT_PROGRESS      TRUE
    EXCLUDE_FROM_ALL  TRUE
    BINARY_DIR        ${NAME}
    PREFIX            ${CACHE_DIR}/.prefix/${NAME}
    SOURCE_DIR        ${CACHE_DIR}/${NAME}
    SUBBUILD_DIR      ${CACHE_DIR}/.prefix/${NAME}/sub
    PATCH_COMMAND     ${__PATCH}
    SOURCE_SUBDIR     ${SOURCE_SUBDIR}
  )

  GitTag(${CACHE_DIR}/${NAME} VERSION)

  if("${TAG}" STREQUAL "${VERSION}")
    string(TOUPPER FETCHCONTENT_UPDATES_DISCONNECTED_${NAME} UPDATE)
    set(${UPDATE} ON PARENT_SCOPE)
  endif()

  set(_LIST ${FetchList})
  list(APPEND _LIST ${NAME})
  set(FetchList ${_LIST} PARENT_SCOPE)
endfunction()

function(AddDependencies Dependencies)
  set(_LIST ${Dependencies} ${ARGN})
  set(FetchList PARENT_SCOPE)
  set(FetchList_NeedsPreload PARENT_SCOPE)

  foreach(dependency ${_LIST})
    include(${dependency})
  endforeach()

  FetchContent_MakeAvailable(${FetchList})

  foreach(dependency ${FetchList_NeedsPreload})
    foreach(Preload ${FetchList_NeedsPreload_${dependency}})
      add_subdirectory(${CACHE_DIR}/${dependency}/${Preload})
    endforeach()
    add_subdirectory(${CACHE_DIR}/${dependency})
  endforeach()
endfunction()

function(GitTag DIR OUT)
  execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
    WORKING_DIRECTORY ${DIR}
    OUTPUT_VARIABLE VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  if("${VERSION}" STREQUAL "")
  execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${DIR}
    OUTPUT_VARIABLE VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  endif()
  set(${OUT} ${VERSION} PARENT_SCOPE)
endfunction()

function(AppendPath)
  set(options)
  set(oneValueArgs PATCH)
  set(multiValueArgs AFTER BEFORE)

  cmake_parse_arguments(_ "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(_PATH ${__BEFORE} $ENV{PATH} ${__AFTER})
  cmake_path(CONVERT "${_PATH}" TO_NATIVE_PATH_LIST _PATH NORMALIZE)
  set(ENV{PATH} "${_PATH}") 
endfunction()

function(WriteIfChanged DESTINATION TEXT)
set(Changed FALSE)
if(EXISTS ${DESTINATION})
  file(STRINGS ${DESTINATION} compare_string NEWLINE_CONSUME)
  string(REPLACE "\\;" "\;" compare_string ${compare_string})
  string(COMPARE EQUAL
    "${compare_string}"
    "${TEXT}"
    Changed
  )
endif()
if(NOT ${Changed})
  file(WRITE ${DESTINATION} "${TEXT}")
endif()
endfunction()

function(Configure FILE_IN FILE_OUT)
set(COPY_REMARK "\
# Do not edit!
# This file was auto-generated
# Source: ${FILE_IN}
")
configure_file(${FILE_IN} ${FILE_OUT} @ONLY NEWLINE_STYLE UNIX)
endfunction()