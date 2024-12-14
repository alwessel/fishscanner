#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

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
    [[ "$version" == "3.11" ]]
}

# Function to check OpenGL
check_opengl() {
    python3 -c "import OpenGL.GL" 2>/dev/null
}

# Function to check camera permissions (on macOS)
check_camera_permissions() {
    if ! python3 -c "import cv2; cap = cv2.VideoCapture(0)" 2>/dev/null; then
        echo "⚠️  Camera access may be required"
        echo "Please grant camera permissions in System Settings → Privacy & Security → Camera"
        echo "Then try running this script again"
        exit 1
    fi
}

echo "🐠 Starting FishScanner..."

# Check if we're in the right directory
if [ ! -f "main_ocean.py" ]; then
    echo "⚠️  main_ocean.py not found"
    echo "Please run this script from the FishScanner directory"
    exit 1
fi

# Check if virtual environment exists
if ! check_venv; then
    echo "⚠️  Virtual environment not found or invalid"
    echo "Please run ./setup.sh first"
    exit 1
fi

# Activate virtual environment
source venv/bin/activate || {
    echo "⚠️  Failed to activate virtual environment"
    echo "Please run ./setup.sh to recreate it"
    exit 1
}

# Verify Python version
if ! check_python_version; then
    echo "⚠️  Wrong Python version (expected 3.11)"
    echo "Please run ./setup.sh to fix Python environment"
    exit 1
fi

# Verify OpenGL
if ! check_opengl; then
    echo "⚠️  OpenGL not working properly"
    echo "Please try:"
    echo "1. Log out and log back in"
    echo "2. Run: brew reinstall freeglut"
    exit 1
fi

# Start XQuartz if it's not running
if ! is_xquartz_running; then
    echo "Starting XQuartz..."
    open -a XQuartz
    
    # Wait for XQuartz to start (with timeout)
    echo -n "Waiting for XQuartz to initialize..."
    for i in {1..10}; do
        if is_xquartz_running; then
            echo " ready!"
            break
        fi
        if [ "$i" -eq 10 ]; then
            echo " timeout!"
            echo "⚠️  XQuartz failed to start"
            echo "Please try:"
            echo "1. Run: open -a XQuartz"
            echo "2. Log out and log back in"
            echo "3. Try running this script again"
            exit 1
        fi
        echo -n "."
        sleep 1
    done
fi

# Set display for OpenGL
export DISPLAY=:0

# Check camera permissions
check_camera_permissions

# Run the application
echo "Starting FishScanner application..."
python3 main_ocean.py || {
    echo "⚠️  Application crashed"
    echo "Please check:"
    echo "1. Camera permissions"
    echo "2. XQuartz is running"
    echo "3. The error message above"
    exit 1
}
