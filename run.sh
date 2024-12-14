#!/bin/bash

# Function to check if XQuartz is running
is_xquartz_running() {
    pgrep -x "Xquartz" >/dev/null
}

echo "🐠 Starting FishScanner..."

# Start XQuartz if it's not running
if ! is_xquartz_running; then
    echo "Starting XQuartz..."
    open -a XQuartz
    
    # Wait for XQuartz to start
    echo "Waiting for XQuartz to initialize..."
    sleep 3
fi

# Set display for OpenGL
export DISPLAY=:0

# Activate virtual environment
source venv/bin/activate

# Run the application
echo "Starting FishScanner application..."
python3 main_ocean.py
