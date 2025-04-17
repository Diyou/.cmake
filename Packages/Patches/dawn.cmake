execute_process(COMMAND
    ${CMAKE_COMMAND} -E copy_if_different scripts/standalone.gclient .gclient
)

set(ENV{DEPOT_TOOLS_UPDATE} FALSE)
set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} FALSE)

if(WIN32)
set(ENV{DEPOT_TOOLS_UPDATE} TRUE)

execute_process(COMMAND
    cmd /c gclient
)
endif()

execute_process(COMMAND
    gclient sync -D
)
