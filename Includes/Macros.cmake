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

# Shorthand for add_executable(name)
macro(EXE name)
  if(ANDROID)
    DLL(${name} ${ARGN})
    set_target_properties(${name} PROPERTIES
        OUTPUT_NAME main
    )
  else()
    add_executable(${name} WIN32)
    _add_sources(${name} ${ARGN})
  endif()
endmacro()

macro(ALIAS target alias)
  add_library(${alias} ALIAS ${target})
endmacro()

macro(RunOnlyOnce)
  get_filename_component(SCRIPT_NAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
  if(DEFINED ${SCRIPT_NAME}_INCLUDED)
      return()
  endif()
  set(${SCRIPT_NAME}_INCLUDED ON)
endmacro()


function(AppendPath)
  set(options)
  set(oneValueArgs PATCH)
  set(multiValueArgs AFTER BEFORE)

  cmake_parse_arguments(_ "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(_PATH ${__BEFORE} $ENV{PATH} ${__AFTER})
  cmake_path(CONVERT "${_PATH}" TO_NATIVE_PATH_LIST _PATH NORMALIZE)
  set(ENV{PATH} "${_PATH}") 
endfunction()

macro(AddQuotes var)
  if(NOT ${ARGV1} EQUAL "")
    set(${var} "\"${ARGV1}\"")
  else()
    set(${var} "\"${${var}}\"")
  endif()
endmacro()

function(SetJSON json key value)
  if(NOT json)
    return()
  endif()

  string(JSON elements LENGTH "${${json}}")
  if(NOT elements OR elements EQUAL 0)
    return()
  endif()

  if("${value}" STREQUAL "")
    string( JSON ${json} 
            REMOVE "${${json}}"
            "${key}"
    )
  else()
    string( JSON ${json} 
            SET "${${json}}"
            "${key}"
            "${value}"
    )
  endif()
  set(${json} ${${json}} PARENT_SCOPE)
endfunction()

function(UpdateJSONFile source key value)
  file(READ ${source} content)
  SetJSON(content ${key} "${value}")

  if(content)
      WriteIfChanged(${source} "${content}")
  endif()
endfunction()

function(WriteIfChanged DESTINATION TEXT)
  set(NEEDS_UPDATE TRUE)
  if(EXISTS ${DESTINATION})
    file(STRINGS ${DESTINATION} compare_string NEWLINE_CONSUME)
    string(REPLACE "\\;" "\;" compare_string ${compare_string})
    string(COMPARE NOTEQUAL
      "${compare_string}"
      "${TEXT}"
      NEEDS_UPDATE
    )
  endif()
  if(NEEDS_UPDATE)
    file(WRITE ${DESTINATION} "${TEXT}")
  endif()
endfunction()

function(Configure FILE_IN FILE_OUT)
set(COPY_REMARK "\
#  Do not edit!
#  This file was auto-generated
#  Source: ${FILE_IN}
")
configure_file(${FILE_IN} ${FILE_OUT} @ONLY NEWLINE_STYLE UNIX)
endfunction()
