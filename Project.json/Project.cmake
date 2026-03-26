include_guard(GLOBAL)

if(NOT EXISTS "${PROJECT_ROOT}/Project.json")
    message(FATAL_ERROR "/Project.json missing")
endif()

# Watch for changes
set_directory_properties(PROPERTIES
    CMAKE_CONFIGURE_DEPENDS "${PROJECT_ROOT}/Project.json"
)

file(READ ${PROJECT_ROOT}/Project.json JSON)

GetJSON(JSON Project DOTCMAKE_PROJECT_JSON)
if(NOT DOTCMAKE_PROJECT_JSON)
    message(FATAL_ERROR [["Project" property missing in Project.json]])
endif()
GetJSON(DOTCMAKE_PROJECT_JSON   Name        DOTCMAKE_PROJECT_NAME)
GetJSON(DOTCMAKE_PROJECT_JSON   ID          DOTCMAKE_PROJECT_ID)
GetJSON(DOTCMAKE_PROJECT_JSON   Version     DOTCMAKE_PROJECT_VERSION)
GetJSON(DOTCMAKE_PROJECT_JSON   Description DOTCMAKE_PROJECT_DESCRIPTION)
GetJSON(DOTCMAKE_PROJECT_JSON   URL         DOTCMAKE_PROJECT_URL)

unset(__MISSING_PROPERTIES)
if(NOT DOTCMAKE_PROJECT_NAME)
    list(APPEND __MISSING_PROPERTIES Name)
endif()
if(NOT DOTCMAKE_PROJECT_ID)
    list(APPEND __MISSING_PROPERTIES ID)
endif()
if(NOT DOTCMAKE_PROJECT_VERSION)
    list(APPEND __MISSING_PROPERTIES Version)
endif()

if(__MISSING_PROPERTIES)
    message(FATAL_ERROR [["Project" requires additional properties: ]] "(${__MISSING_PROPERTIES})")
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
    GetJSON(JSON Depends JSON_deps)
    GetJSONKeys(JSON_deps dependencies)

    # Shared helpers
    macro(FAIL)
        set(SUCCESS FALSE)
        set(SUCCESS ${SUCCESS} PARENT_SCOPE)
    endmacro()

    macro(PREPARE_PATCH)
        set(APPLY_PATCH FALSE)
        set(APPLY_PATCH ${SUCCESS} PARENT_SCOPE)
    endmacro()
    
    macro(Uninstall)
        message("Removing '${DEPENDENCY}' ...")
        file(REMOVE_RECURSE "${DEPENDENCY_DIR}")
    endmacro()
    
    include("${CMAKE_CURRENT_LIST_DIR}/Archive.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/Git.cmake")

    function(Parse)
        GetJSON(JSON_deps "${DEPENDENCY}" JSON)

        # Shared variables
        set(DEPENDENCY_ROOT "${CACHE_DIR}")
        set(DEPENDENCY_DIR "${DEPENDENCY_ROOT}/${DEPENDENCY}")

        set(SUCCESS TRUE)
        set(APPLY_PATCH FALSE)
        
        GetJSON(JSON type type)
        if(type STREQUAL
        "archive")
            ParseArchiveDependency()
        elseif(type STREQUAL
        "git")
            ParseGITDependency()
        else()
            message(WARNING "[Project.json] Dependency type '${type}' is not supported")
            return()
        endif()

        if(NOT SUCCESS)
            return()
        endif()

        # Apply patch
        if(${APPLY_PATCH})
            GetJSON(JSON patch patch)
            if(patch)
                message("Applying patch for ${DEPENDENCY}...")
                if(EXISTS "${PROJECT_ROOT}/${patch}")
                    list(APPEND CMAKE_MESSAGE_INDENT "[PATCH] ")
                    include("${PROJECT_ROOT}/${patch}")
                    list(POP_BACK CMAKE_MESSAGE_INDENT)
                endif()
            endif()
        endif()

        # Add config
        GetJSON(JSON config config)
        if(config AND EXISTS "${PROJECT_ROOT}/${config}")
            list(APPEND CMAKE_MESSAGE_INDENT "[CONFIG] ")
            include("${PROJECT_ROOT}/${config}")
            list(POP_BACK CMAKE_MESSAGE_INDENT)
        endif()

        # Add subdirectory
        if(EXISTS "${DEPENDENCY_DIR}/CMakeLists.txt")
            add_subdirectory("${DEPENDENCY_DIR}" EXCLUDE_FROM_ALL)
        endif()
    endfunction()

    foreach(DEPENDENCY ${dependencies})
        list(APPEND CMAKE_MESSAGE_INDENT "[${DEPENDENCY}] ")
        Parse()
        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endforeach()
endfunction()

_LOAD_PROJECT_JSON_DEPENDENCIES()
