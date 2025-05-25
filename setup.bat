@echo off
setlocal

:: Get the directory where the script is located
set "SCRIPT_DIR=%~dp0"

:: Define the parent directory relative to the script
set "PARENT_DIR=%SCRIPT_DIR%Templates"

:: Check if exactly one argument is provided
if "%~1"=="" (
    echo Error: Please provide the name of a Template
    echo Usage: %0 ^<template^>
    echo Available Templates::
    if exist "%PARENT_DIR%\" (
        dir "%PARENT_DIR%" /AD /B
    ) else (
        echo   (No 'Templates' directory found relative to script)
    )
    exit /b 1
)

:: Store the subdirectory name
set "SUBDIR=%PARENT_DIR%\%~1"

:: Check if the subdirectory exists
if not exist "%SUBDIR%\" (
    echo Error: Template '%~1' does not exist
    echo Available Templates in '%PARENT_DIR%':
    if exist "%PARENT_DIR%\" (
        dir "%PARENT_DIR%" /AD /B
    ) else (
        echo   (No 'Templates' directory found relative to script)
    )
    exit /b 1
)

:: Copy all files from subdirectory to current directory
xcopy "%SUBDIR%\*.*" . /Y >nul

:: Check if copy was successful
if %ERRORLEVEL% equ 0 (
    echo Successfully copied files from '%SUBDIR%' to current directory
) else (
    echo Error: Failed to copy files from '%SUBDIR%'
    exit /b 1
)

endlocal
