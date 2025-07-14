if(NOT EXISTS ${PROJECT_ROOT}/Project.json)
    message(FATAL_ERROR "/Project.json missing")
endif()

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
