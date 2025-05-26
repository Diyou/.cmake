@echo off
setlocal enabledelayedexpansion

:: Get the script's directory
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

:: Define the parent directory relative to the script
set PARENT_DIR=%SCRIPT_DIR%\Templates

:: Check if exactly one argument is provided
if "%~1"=="" (
    echo Error: Please provide the name of a Template
    echo Usage: %0 ^<template^>
    echo Available Templates:
    if exist "%PARENT_DIR%" (
        for /d %%d in ("%PARENT_DIR%\*") do echo   %%~nxd
    ) else (
        echo   (No 'Templates' directory found relative to script)
    )
    exit /b 1
)

:: Store the subdirectory name
set SUBDIR=%PARENT_DIR%\%~1

:: Check if the subdirectory exists
if not exist "%SUBDIR%" (
    echo Error: Template '%~1' does not exist
    echo Available Templates:
    if exist "%PARENT_DIR%" (
        for /d %%d in ("%PARENT_DIR%\*") do echo   %%~nxd
    ) else (
        echo   (No 'Templates' directory found relative to script)
    )
    exit /b 1
)

:: Print the absolute target directory
echo Copying files to: %CD%

:: Initialize copy success flag
set copy_success=1

:: Call the recursive copy and print function
call :copy_and_print_tree "%SUBDIR%" "  " 0

:: Check if all copies were successful
if %copy_success%==1 (
    dir /b /a "%SUBDIR%" | findstr . >nul && (
        echo Successfully copied files from '%SUBDIR%' to current directory
    ) || (
        echo No files found in '%SUBDIR%' to copy
    )
) else (
    echo Error: One or more files failed to copy from '%SUBDIR%'
    exit /b 1
)

exit /b 0

:: Recursive function to copy and print tree structure
:copy_and_print_tree
set "dir=%~1"
set "indent=%~2"
set "is_last=%~3"

:: List items in the directory
set item_count=0
for /f "delims=" %%i in ('dir /b /a "%dir%"') do (
    set /a item_count+=1
    set "items[!item_count!]=%%i"
)

:: Process each item
for /l %%n in (1,1,%item_count%) do (
    set "item=%dir%\!items[%%n]!"
    set "base=!items[%%n]!"
    set "is_dir=0"
    if exist "!item!\*" (
        set "is_dir=1"
        set "base=!base!\"
    )

    :: Determine prefix
    set "prefix=├──"
    if %%n==%item_count% (
        set "prefix=└──"
    )

    :: Print the item
    echo %indent%!prefix! !base!

    :: Copy the item
    set "rel_path=!item:%SUBDIR%\=!"
    if !is_dir!==1 (
        xcopy /e /i /y "!item!" "%CD%\!rel_path!" >nul 2>&1 || (
            echo %indent%    Error: Failed to copy '!base!'
            set copy_success=0
        )
    ) else (
        copy /y "!item!" "%CD%\!rel_path!" >nul 2>&1 || (
            echo %indent%    Error: Failed to copy '!base!'
            set copy_success=0
        )
    )

    :: If it's a directory, recurse with proper indentation
    if !is_dir!==1 (
        set "new_indent=%indent%    "
        if %%n==%item_count% (
            set "new_indent=%indent%    "
        ) else (
            set "new_indent=%indent%│   "
        )
        call :copy_and_print_tree "!item!" "!new_indent!" %%n
    )
)
exit /b
