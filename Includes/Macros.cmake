set(CACHE_DIR_RELATIVE .cache)
set(CACHE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${CACHE_DIR_RELATIVE})

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
function(EXE name)
  if(ANDROID)
    DLL(${name} ${ARGN})
    set_target_properties(${name} PROPERTIES
        OUTPUT_NAME main
    )
  else()
    add_executable(${name} WIN32)
    _add_sources(${name} ${ARGN})
    if(EMSCRIPTEN)
      set(EMSCRIPTEN_SHELL "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../ToolChains/EmscriptenShell.html")
      target_link_options(${name}
        PRIVATE
          -sENVIRONMENT=web
          --shell-file=${EMSCRIPTEN_SHELL}
        $<$<CONFIG:Debug>:
          --emrun
        >
      )
      set_target_properties(${name} PROPERTIES
          SUFFIX .html
          LINK_DEPENDS ${EMSCRIPTEN_SHELL}
      )
    endif()
  endif()
endfunction()

macro(ALIAS target alias)
  add_library(${alias} ALIAS ${target})
endmacro()

macro(RunOnlyOnce)
  cmake_path(GET CMAKE_CURRENT_LIST_FILE STEM SCRIPT_NAME)
  if(DEFINED ${SCRIPT_NAME}_INCLUDED)
      return()
  endif()
  set(${SCRIPT_NAME}_INCLUDED ON)
endmacro()

macro(CacheInternal variable)
  set(${variable} "${${variable}}" CACHE INTERNAL "")
endmacro()

macro(CacheString variable description)
  set(${variable} "${${variable}}" CACHE STRING "${description}")
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

function(ValidJSON json outVar)
  string(JSON elements ERROR_VARIABLE error LENGTH "${${json}}")
  if(error)
    set(${outVar} false PARENT_SCOPE)
  else()
    set(${outVar} true PARENT_SCOPE)
  endif()
endfunction()

function(EqualJSON left right outVar)
  string(JSON equals ERROR_VARIABLE error EQUAL "${${left}}" "${${right}}")
  if(error OR NOT equals)
    set(${outVar} false PARENT_SCOPE)
  else()
    set(${outVar} true PARENT_SCOPE)
  endif()
endfunction()

function(GetJSON json key value)
  string(JSON ${value} ERROR_VARIABLE error GET "${${json}}" "${key}")
  set(${value} ${${value}} PARENT_SCOPE)
endfunction()

function(GetJSONKeys json keysOut)
  string(JSON item_count LENGTH "${${json}}")
  set(items "")
  math(EXPR end "${item_count} - 1")
  foreach(i RANGE ${end})
    string(JSON key MEMBER "${${json}}" ${i})
    list(APPEND items ${key})
  endforeach()
  set(${keysOut} ${items} PARENT_SCOPE)
endfunction()

function(GetJSONArray json value)
  unset(array)
  string(JSON elements LENGTH "${json}")
  if(elements GREATER 0)
    math(EXPR LAST_INDEX "${elements} - 1")
    foreach(INDEX RANGE 0 ${LAST_INDEX})
      string(JSON element GET "${json}" ${INDEX})
      list(APPEND array "${element}")
    endforeach()
  endif()
  set(${value} "${array}" PARENT_SCOPE)
endfunction()

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

function(Download url destination result)
  message("Downloading ${url}...")
  file(DOWNLOAD "${url}" "${destination}"
#    SHOW_PROGRESS
    TLS_VERIFY ON
    STATUS status
  )
  set(${result} ${status} PARENT_SCOPE)
endfunction()

function(Extract archive destination)
  message("Extracting ${${archive}} ...")
  file(ARCHIVE_EXTRACT
    INPUT "${${archive}}"
    DESTINATION "${${destination}}"
#    VERBOSE
  )
endfunction()

function(GitTag dir outVar)
  execute_process(COMMAND ${GIT_EXECUTABLE}
          describe --tags --exact-match
          WORKING_DIRECTORY "${dir}"
          OUTPUT_VARIABLE out
          RESULT_VARIABLE result
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(result EQUAL 0)
    set(${outVar} ${out} PARENT_SCOPE)
    return()
  endif()
  execute_process(COMMAND ${GIT_EXECUTABLE}
          rev-parse HEAD
          WORKING_DIRECTORY "${dir}"
          OUTPUT_VARIABLE out
          RESULT_VARIABLE result
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(${outVar} ${out} PARENT_SCOPE)
endfunction()

function(EQUALS_SHA256 file hash outVar)
  file(SHA256 "${${file}}" file_hash)
  string(REPLACE sha256: "" hash "${${hash}}")

  if(file_hash STREQUAL hash)
    set(${outVar} true PARENT_SCOPE)
  else()
    set(${outVar} false PARENT_SCOPE)
  endif()
endfunction()
