@echo off
setlocal EnableDelayedExpansion

:: Get the directory where the script is located
set "SCRIPT_DIR=%~dp0"

:: Define the parent directory relative to the script
set "PARENT_DIR=%SCRIPT_DIR%Templates"

:: Check if exactly one argument is provided
if "%~1"=="" (
    echo Error: Please provide the name of a Template
    echo Usage: %0 ^<template^>
    echo Available Templates:
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

:: Print the absolute target directory
echo Copying files to: %CD%

:: List files with relative paths
for /f "delims=" %%F in ('xcopy "%SUBDIR%\*.*" . /E /H /L /Y') do (
    :: Skip lines that are not file paths
    echo "%%F" | findstr /R /C:".* -> .*" >nul
    if !errorlevel! equ 0 (
        :: Extract relative path by removing SUBDIR
        set "full_path=%%F"
        set "relative_path=!full_path:%SUBDIR%\=!"
        :: Extract only the source file name (before ->)
        for /f "tokens=1 delims=->" %%A in ("!relative_path!") do (
            set "file_name=%%A"
            :: Trim leading spaces
            for /f "tokens=*" %%B in ("!file_name!") do (
                echo     Copying: %%B
            )
        )
    )
)

:: Perform the actual copy
xcopy "%SUBDIR%\*.*" . /E /H /Y >nul

:: Check if copy was successful
if %ERRORLEVEL% equ 0 (
    dir "%SUBDIR%" /A-D /B >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        echo Successfully copied files from '%SUBDIR%' to current directory
    ) else (
        echo No files found in '%SUBDIR%' to copy
    )
) else (
    echo Error: Failed to copy files from '%SUBDIR%'
    exit /b 1
)

endlocal