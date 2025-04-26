set(DAWN_TAG chromium/7132)
set(DAWN_URL https://dawn.googlesource.com/dawn)

set(DAWN_FETCH_DEPENDENCIES OFF)

set(DAWN_BUILD_SAMPLES OFF)
set(DAWN_BUILD_BENCHMARKS OFF)

if(LINUX)
  set(DAWN_USE_X11 ON)
  set(DAWN_USE_WAYLAND ON)
endif()

set(DEPOT_TOOLS third_party/depot_tools)
set(DEPOT_TOOLS_DIR ${CACHE_DIR}/dawn/${DEPOT_TOOLS})
AppendPath(BEFORE ${DEPOT_TOOLS_DIR})

DeclareDependency(dawn ${DAWN_URL} ${DAWN_TAG}
SUBMODULES
  ${DEPOT_TOOLS}
PATCH
  ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/Patches/dawn.cmake
)
