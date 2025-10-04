include_guard(GLOBAL)

if(NOT EXISTS ${PROJECT_ROOT}/Project.json)
    message(FATAL_ERROR "/Project.json missing")
endif()

# Watch for changes
set_directory_properties(PROPERTIES
    CMAKE_CONFIGURE_DEPENDS "${PROJECT_ROOT}/Project.json"
)

file(READ ${PROJECT_ROOT}/Project.json JSON)

GetJSON(JSON Project DOTCMAKE_PROJECT_JSON)
if(NOT DOTCMAKE_PROJECT_JSON)
    message(FATAL_ERROR "Project node missing in Project.json")
endif()
GetJSON(DOTCMAKE_PROJECT_JSON   Name        DOTCMAKE_PROJECT_NAME)
GetJSON(DOTCMAKE_PROJECT_JSON   ID          DOTCMAKE_PROJECT_ID)
GetJSON(DOTCMAKE_PROJECT_JSON   Version     DOTCMAKE_PROJECT_VERSION)
GetJSON(DOTCMAKE_PROJECT_JSON   Description DOTCMAKE_PROJECT_DESCRIPTION)
GetJSON(DOTCMAKE_PROJECT_JSON   URL         DOTCMAKE_PROJECT_URL)

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
function(_LOAD_PROJECT_JSON_DEPENDENCIES)
    list(APPEND CMAKE_MESSAGE_INDENT "[Dependency] ")
    set(_CACHE_FILE "${CACHE_DIR}/Project.DEPS.json")

    if(EXISTS "${_CACHE_FILE}")
        file(READ "${_CACHE_FILE}" _CACHE)
        ValidJSON(_CACHE valid)
        if(NOT valid)
            set(_CACHE {})
        endif()
    else()
        set(_CACHE {})
    endif()

    GetJSON(JSON Depends JSON)

    # Helper macros
    function(RequiredProperties)
        set(PROPERTIES ${ARGN} PARENT_SCOPE)
        foreach(property ${ARGN})
            GetJSON(dependency ${property} json)
            set(${property} "${json}" PARENT_SCOPE)
        endforeach()
    endfunction()

    function(RequiredPropertiesMatchCached result)
        GetJSON(_CACHE ${name} cached)

        foreach(property ${PROPERTIES})
            GetJSON(cached ${property} cached_property)
            GetJSON(dependency ${property} property)
            if(NOT property STREQUAL cached_property)
                set(${result} false PARENT_SCOPE)
                return()
            endif()
        endforeach()

        set(${result} true PARENT_SCOPE)
    endfunction()

    macro(_Uninstall)
        file(REMOVE_RECURSE "${destination}")
    endmacro()

    function(SETUP_archive)
        cmake_path(GET url FILENAME archive_file)
        set(archive_destination "${destination}/../${name}_${archive_file}")
        set(destination_tmp "${destination}/../_${name}")
        get_filename_component(archive_destination "${archive_destination}" REALPATH)
        get_filename_component(destination_tmp "${destination_tmp}" REALPATH)

        macro(_Download)
            Download("${url}" "${archive_destination}" result)
            list(GET result 1 error)
            list(GET result 0 result)
            if(NOT result EQUAL 0)
                message(WARNING "${error}")
                set(success false)
                return()
            endif()
        endmacro()

        macro(_CheckHash)
            if(sha256)
                EQUALS_SHA256(archive_destination sha256 same)
                if(NOT same)
                    message(WARNING "Hash of ${archive_file} did not match ${sha256}")
                    file(REMOVE "${archive_destination}")
                    set(success false)
                    return()
                endif()
            endif()
        endmacro()

        if(NOT EXISTS "${archive_destination}")
            _Download()
        endif()

        _CheckHash()

        # Extract
        Extract(archive_destination destination_tmp)

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
    endfunction()

    function(UPDATE_archive)
        _Uninstall()
        SETUP_archive()
    endfunction()

    function(SETUP_git)
        set(_clone_args -c advice.detachedHead=false)
        if(shallow)
            set(_clone_args ${_clone_args} --depth=2 --no-single-branch --shallow-submodules)
        endif()

        execute_process(COMMAND ${GIT_EXECUTABLE}
                clone ${_clone_args} --no-checkout ${url} ${name}
                WORKING_DIRECTORY "${CACHE_DIR}"
                RESULT_VARIABLE result
        )
        if(NOT result EQUAL 0)
            message(WARNING "Failed to clone '${name}'")
            set(success false)
            _Uninstall()
            return()
        endif()
        execute_process(COMMAND ${GIT_EXECUTABLE}
                checkout ${tag}
                WORKING_DIRECTORY "${CACHE_DIR}/${name}"
                RESULT_VARIABLE result
        )
        if(NOT result EQUAL 0)
            message(WARNING "Failed to checkout '${name}'")
            set(success false)
            _Uninstall()
            return()
        endif()
        set(APPLY_PATCH true)
    endfunction()

    function(UPDATE_git)
        GetJSON(cached tag cached_tag)
        if(cached_tag STREQUAL tag)
            return()
        endif()
        execute_process(COMMAND ${GIT_EXECUTABLE}
            checkout ${tag}
            WORKING_DIRECTORY "${CACHE_DIR}/${name}"
            RESULT_VARIABLE result
        )
        if(NOT result EQUAL 0)
            message(WARNING "Failed to update '${name}'")
            set(success false)
            return()
        endif()
        set(APPLY_PATCH true)
    endfunction()

    macro(_Finalize)
        if(success)
            string(JSON _CACHE SET ${_CACHE} ${name} ${dependency})
            # Apply patch
            if(APPLY_PATCH AND patch)
                message("Applying patch for ${name}...")
                if(EXISTS "${PROJECT_ROOT}/${patch}")
                    include("${PROJECT_ROOT}/${patch}")
                endif()
            endif()
            # Add config
            if(config AND EXISTS "${PROJECT_ROOT}/${config}")
                include("${PROJECT_ROOT}/${config}")
            endif()
            # Add subdirectory
            if(EXISTS "${destination}/CMakeLists.txt")
                add_subdirectory("${destination}" EXCLUDE_FROM_ALL)
            endif()
        else()
            message(FATAL_ERROR "Failed to load ${name}")
        endif()
    endmacro()

    # Logic
    if(JSON)
        GetJSONKeys(JSON dependencies)
        foreach(dependency ${dependencies})
            set(name ${dependency})
            message("Load ${name}")
            set(destination "${CACHE_DIR}/${name}")
            GetJSON(JSON ${dependency} dependency)
            # Required variables:
            set(success true)       # No errors
            set(APPLY_PATCH false)  # Files changed and Patching required if there are any

            GetJSON(dependency type type)
            GetJSON(dependency patch patch)
            GetJSON(dependency config config)

            if(type STREQUAL "archive")
                RequiredProperties(url sha256)

                # Installation
                if(NOT IS_DIRECTORY "${destination}")
                    SETUP_archive()
                    _Finalize()
                    continue()
                endif()

                # Update
                RequiredPropertiesMatchCached(same)

                # No changes
                if(same)
                    _Finalize()
                    continue()
                endif()

                # With changes
                # Reinstall required
                _Uninstall()
                SETUP_archive()
                _Finalize()
            elseif(type STREQUAL "git")
                RequiredProperties(url tag shallow)

                # Installation
                if(NOT IS_DIRECTORY "${destination}")
                    SETUP_git()
                    _Finalize()
                    continue()
                endif()

                # Update
                RequiredPropertiesMatchCached(same)

                # No changes
                if(same)
                    _Finalize()
                    continue()
                endif()

                # With changes
                GetJSON(cached type cached_type)
                if(cached_type STREQUAL type)
                    UPDATE_git()
                    _Finalize()
                    continue()
                endif()

                # Try to recuperate
                GitTag(${destination} old_tag)
                if(old_tag STREQUAL tag)
                    _Finalize()
                    continue()
                endif()

                # Reinstall required
                _Uninstall()
                SETUP_git()
                _Finalize()
            else()
                message(FATAL_ERROR "Project.json: Type '${type}' is not supported")
                continue()
            endif ()
        endforeach ()
    endif()
    WriteIfChanged("${_CACHE_FILE}" "${_CACHE}")
    list(POP_BACK CMAKE_MESSAGE_INDENT)
endfunction()
_LOAD_PROJECT_JSON_DEPENDENCIES()
