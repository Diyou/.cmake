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
