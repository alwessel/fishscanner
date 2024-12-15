#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PYTHON_VERSION="3.11"
XQUARTZ_TIMEOUT=10
LOG_FILE="fishscanner.log"
REQUIRED_DIRS=("photos" "ocean/patterns")

# Logging setup
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Function to show progress
show_progress() {
    echo -e "${BLUE}$1${NC}"
}

# Function to show error and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}"
    echo "Check $LOG_FILE for details"
    exit 1
}

# Function to show warning
show_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Function to check if XQuartz is running (checking both process names)
is_xquartz_running() {
    pgrep -f "XQuartz" >/dev/null || pgrep -f "Xorg" >/dev/null
}

# Function to check if virtual environment exists and is valid
check_venv() {
    [ -d "venv" ] && [ -f "venv/bin/activate" ] && [ -f "venv/bin/python3" ]
}

# Function to check Python version
check_python_version() {
    local version
    version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    [[ "$version" == "$PYTHON_VERSION" ]]
}

# Function to check OpenGL
check_opengl() {
    python3 -c "import OpenGL.GL" 2>/dev/null
}

# Function to check required directories
check_directories() {
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            error_exit "Required directory '$dir' not found"
        fi
    done
}

# Function to start XQuartz
start_xquartz() {
    if ! is_xquartz_running; then
        show_progress "Starting XQuartz..."
        open -a XQuartz
        
        # Wait for XQuartz to start (with timeout)
        echo -n "Waiting for XQuartz to initialize..."
        for i in $(seq 1 $XQUARTZ_TIMEOUT); do
            if is_xquartz_running; then
                echo -e " ${GREEN}ready!${NC}"
                return 0
            fi
            echo -n "."
            sleep 1
        done
        
        echo -e " ${RED}timeout!${NC}"
        echo "Please try:"
        echo "1. Run: open -a XQuartz"
        echo "2. Log out and log back in"
        echo "3. Try running this script again"
        return 1
    fi
}

# Main function
main() {
    show_progress "🐠 Starting FishScanner..."
    echo "Log file: $LOG_FILE"
    
    # Clear log file
    > "$LOG_FILE"
    
    # Check if we're in the right directory
    if [ ! -f "main_ocean.py" ]; then
        error_exit "main_ocean.py not found. Please run this script from the FishScanner directory"
    fi
    
    # Check required directories
    check_directories
    
    # Check virtual environment
    if ! check_venv; then
        error_exit "Virtual environment not found or invalid. Please run ./setup.sh first"
    fi
    
    # Activate virtual environment
    source venv/bin/activate || error_exit "Failed to activate virtual environment. Please run ./setup.sh to recreate it"
    
    # Verify Python version
    if ! check_python_version; then
        error_exit "Wrong Python version (expected $PYTHON_VERSION). Please run ./setup.sh to fix Python environment"
    fi
    
    # Verify OpenGL
    if ! check_opengl; then
        error_exit "OpenGL not working properly. Please try:\n1. Log out and log back in\n2. Run: brew reinstall freeglut"
    fi
    
    # Start XQuartz
    if ! start_xquartz; then
        error_exit "Failed to start XQuartz"
    fi
    
    # Set display for OpenGL
    export DISPLAY=:0
    
    # Run the application
    show_progress "Starting FishScanner application..."
    python3 main_ocean.py
    exit_code=$?

    # Exit code 0 means normal termination (ESC pressed)
    if [ $exit_code -eq 0 ]; then
        echo -e "\nThanks for using FishScanner!"
        exit 0
    else
        echo -e "\nFishScanner encountered an error (exit code: $exit_code)"
        exit $exit_code
    fi
}

# Run main function
main
