#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define the parent directory relative to the script
PARENT_DIR="$SCRIPT_DIR/Templates"

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Please provide the name of a Template"
    echo "Usage: $0 <template>"
    echo "Available Templates:"
    if [ -d "$PARENT_DIR" ]; then
        ls -d "$PARENT_DIR"/*/ 2>/dev/null | while read -r dir; do
            basename "$dir"
        done
    else
        echo "  (No 'Templates' directory found relative to script)"
    fi
    exit 1
fi

# Store the subdirectory name
SUBDIR="$PARENT_DIR/$1"

# Check if the subdirectory exists
if [ ! -d "$SUBDIR" ]; then
    echo "Error: Template '$1' does not exist"
    echo "Available Templates in '$PARENT_DIR':"
    if [ -d "$PARENT_DIR" ]; then
        ls -d "$PARENT_DIR"/*/ 2>/dev/null | while read -r dir; do
            basename "$dir"
        done
    else
        echo "  (No 'Templates' directory found relative to script)"
    fi
    exit 1
fi

# Copy all files from subdirectory to current directory
cp -r "$SUBDIR"/* .

# Check if copy was successful
if [ $? -eq 0 ]; then
    echo "Successfully copied files from '$SUBDIR' to current directory"
else
    echo "Error: Failed to copy files from '$SUBDIR'"
    exit 1
fi
