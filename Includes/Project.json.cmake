include_guard(GLOBAL)

if(NOT EXISTS ${PROJECT_ROOT}/Project.json)
    message(FATAL_ERROR "/Project.json missing")
endif()

# Watch for changes
set_directory_properties(PROPERTIES
    CMAKE_CONFIGURE_DEPENDS "${PROJECT_ROOT}/Project.json"
)

file(READ ${PROJECT_ROOT}/Project.json JSON)

GetJSON("${JSON}" Project DOTCMAKE_PROJECT_JSON)
if(NOT DOTCMAKE_PROJECT_JSON)
    message(FATAL_ERROR "Project node missing in Project.json")
endif()
GetJSON("${DOTCMAKE_PROJECT_JSON}" Name         DOTCMAKE_PROJECT_NAME)
GetJSON("${DOTCMAKE_PROJECT_JSON}" ID           DOTCMAKE_PROJECT_ID)
GetJSON("${DOTCMAKE_PROJECT_JSON}" Version      DOTCMAKE_PROJECT_VERSION)
GetJSON("${DOTCMAKE_PROJECT_JSON}" Description  DOTCMAKE_PROJECT_DESCRIPTION)
GetJSON("${DOTCMAKE_PROJECT_JSON}" URL          DOTCMAKE_PROJECT_URL)

if(NOT DOTCMAKE_PROJECT_NAME
OR NOT DOTCMAKE_PROJECT_ID
OR NOT DOTCMAKE_PROJECT_VERSION)
    message(FATAL_ERROR "Missing required Values in Project.json")
endif()

CacheString(DOTCMAKE_PROJECT_NAME        "Name value from Project.json")
CacheString(DOTCMAKE_PROJECT_ID          "ID value from Project.json")
CacheString(DOTCMAKE_PROJECT_VERSION     "Version value from Project.json")
CacheString(DOTCMAKE_PROJECT_DESCRIPTION "Description value from Project.json")
CacheString(DOTCMAKE_PROJECT_URL         "URL value from Project.json")

# Filling in defaults
if(NOT PROJECT_VERSION)
    set(PROJECT_VERSION "${DOTCMAKE_PROJECT_VERSION}")
endif()
if(NOT PROJECT_DESCRIPTION)
    set(PROJECT_DESCRIPTION "${DOTCMAKE_PROJECT_DESCRIPTION}")
endif()
if(NOT PROJECT_HOMEPAGE_URL)
    set(PROJECT_HOMEPAGE_URL "${DOTCMAKE_PROJECT_URL}")
endif()

# Dependencies
list(APPEND CMAKE_MESSAGE_INDENT "[Dependency] ")
GetJSON("${JSON}" Depends DOTCMAKE_DEPENDS_JSON)
if(DOTCMAKE_DEPENDS_JSON)
    GetJSONArray("${DOTCMAKE_DEPENDS_JSON}" deps)
    foreach(dependency ${deps})
        GetJSON("${dependency}" type type)
        GetJSON("${dependency}" patch patch)
        GetJSON("${dependency}" config config)
        set(APPLY_PATCH false)
        if(type STREQUAL "archive")
        # archive support
            GetJSON("${dependency}" url url)
            GetJSON("${dependency}" name name)
            cmake_path(GET url FILENAME archive)

            set(destination "${CACHE_DIR}/${name}")
            set(destination_tmp "${CACHE_DIR}/_${name}")
            if(NOT IS_DIRECTORY "${destination}")
                set(archive_destination "${destination}.${archive}")
                if(NOT EXISTS "${archive_destination}")
                    Download("${url}" "${archive_destination}" result)
                    list(GET result 1 error)
                    list(GET result 0 result)
                    if(NOT result EQUAL 0)
                        message(FATAL_ERROR "${error}")
                    endif()
                endif()
                Extract("${archive_destination}" "${destination_tmp}")
                # Check if archive content is flat
                file(GLOB archive_content RELATIVE "${destination_tmp}" "${destination_tmp}/*")
                list(LENGTH archive_content is_flat)
                if( is_flat EQUAL 1
                AND IS_DIRECTORY "${destination_tmp}/${archive_content}")
                    # archive contains content in a single top-level directory
                    file(RENAME "${destination_tmp}/${archive_content}" "${destination}")
                    file(REMOVE_RECURSE "${destination_tmp}")
                else()
                    # archive is flat
                    file(RENAME "${destination_tmp}" "${destination}")
                endif()
                set(APPLY_PATCH true)
            endif()
        elseif(type STREQUAL "git")
        # git support
            GetJSON("${dependency}" url url)
            GetJSON("${dependency}" tag tag)
            GetJSON("${dependency}" shallow shallow)

            cmake_path(GET url STEM name)
            set(destination "${CACHE_DIR}/${name}")
            if(NOT IS_DIRECTORY "${destination}")
                if(shallow)
                    set(shallow --depth=2 --no-single-branch --shallow-submodules)
                else()
                    set(shallow "")
                endif()

                execute_process(COMMAND ${GIT_EXECUTABLE}
                    clone -c advice.detachedHead=false ${shallow} --no-checkout ${url} ${name}
                    WORKING_DIRECTORY "${CACHE_DIR}"
                    RESULT_VARIABLE result
                )
                if(NOT result EQUAL 0)
                    message(WARNING "Failed to clone '${name}'")
                    file(REMOVE_RECURSE "${destination}")
                    continue()
                endif()
                execute_process(COMMAND ${GIT_EXECUTABLE}
                    checkout ${tag}
                    WORKING_DIRECTORY "${CACHE_DIR}/${name}"
                    RESULT_VARIABLE result
                )
            endif()
        else()
            message(FATAL_ERROR "Project.json: Type '${type}' is not supported")
        endif()

        if(APPLY_PATCH AND patch)
            # TODO Handle patch
            message("Applying patch for ${name}...")
        endif()
        
        GetJSON("${dependency}" config config)
        if(config)
            # TODO Apply config before add_subdirectory
        endif()
        # Finally add subdirectory
        if(EXISTS "${destination}/CMakeLists.txt")
            add_subdirectory("${destination}" EXCLUDE_FROM_ALL)
        endif()
    endforeach()
endif()
list(POP_BACK CMAKE_MESSAGE_INDENT)
