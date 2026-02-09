@echo off
setlocal

:: Hardcoded CMake script relative to the script's directory
set CMAKE_SCRIPT=%~dp0Setup.cmake

:: Check if cmake is installed
where cmake >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: cmake is not installed or not found in PATH
    exit /b 1
)

:: Check if the CMake script exists
if not exist "%CMAKE_SCRIPT%" (
    echo Error: CMake script '%CMAKE_SCRIPT%' not found
    exit /b 1
)

:: Run CMake in script mode with the hardcoded script, passing cwd and all arguments
cmake -P "%CMAKE_SCRIPT%" -- "%CD%" %*

exit /b %ERRORLEVEL%
