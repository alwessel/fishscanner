#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if XQuartz is installed
xquartz_installed() {
    [ -d "/Applications/XQuartz.app" ]
}

# Function to check write permissions
check_permissions() {
    local dir="$1"
    if [ ! -w "$dir" ]; then
        echo "⚠️  No write permissions in $dir"
        echo "Please run: sudo chown -R $(whoami) $dir"
        exit 1
    fi
}

# Function to setup shell profile
setup_shell_profile() {
    local profile="$1"
    if [ -f "$profile" ]; then
        if ! grep -q "export DISPLAY=:0" "$profile"; then
            echo "export DISPLAY=:0" >> "$profile"
        fi
        if ! grep -q "opt/homebrew" "$profile" && [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$profile"
        fi
    fi
}

echo "🐠 Setting up FishScanner..."

# Check current directory permissions
check_permissions "$(pwd)"

# Check if Homebrew is installed
if ! command_exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew is already installed"
fi

# Install system dependencies using Homebrew
echo "Installing system dependencies..."
brew install glfw python@3.11 freeglut || {
    echo "⚠️  Error installing system dependencies"
    echo "Try running: brew doctor"
    exit 1
}

# Verify Python 3.11 is available
if ! command_exists python3.11; then
    echo "⚠️  Python 3.11 not found in PATH"
    echo "Try running: brew link python@3.11"
    exit 1
fi

# Verify Python version
PYTHON_VERSION=$(python3.11 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if [[ "$PYTHON_VERSION" != "3.11" ]]; then
    echo "⚠️  Wrong Python version: $PYTHON_VERSION (expected 3.11)"
    exit 1
fi

# Check if XQuartz is installed
if ! xquartz_installed; then
    echo "Installing XQuartz..."
    brew install --cask xquartz
    echo "⚠️  Important: You'll need to log out and log back in for XQuartz to work properly"
else
    echo "✅ XQuartz is already installed"
fi

# Remove existing venv if present
if [ -d "venv" ]; then
    echo "Removing existing virtual environment..."
    rm -rf venv
fi

# Create and activate virtual environment
echo "Setting up Python virtual environment..."
python3.11 -m venv venv || {
    echo "⚠️  Error creating virtual environment"
    echo "Please check Python installation: python3.11 -m venv --help"
    exit 1
}

# Activate virtual environment
source venv/bin/activate || {
    echo "⚠️  Error activating virtual environment"
    exit 1
}

# Upgrade pip
python3 -m pip install --upgrade pip

# Install Python dependencies
echo "Installing Python packages..."
python3 -m pip install -r requirements.txt || {
    echo "⚠️  Error installing Python packages"
    echo "Try running: python3 -m pip install --upgrade pip"
    exit 1
}

# Optional: Install PyOpenGL-accelerate for better performance
echo "Installing optional performance enhancement..."
python3 -m pip install PyOpenGL-accelerate || echo "⚠️  PyOpenGL-accelerate installation failed (this is optional)"

# Setup shell profiles
setup_shell_profile ~/.zshrc
setup_shell_profile ~/.bashrc

# Verify OpenGL
python3 -c "import OpenGL.GL" || {
    echo "⚠️  OpenGL verification failed"
    echo "Please try reinstalling: brew reinstall freeglut"
    exit 1
}

echo """
✨ Setup complete! ✨

To run FishScanner:
1. Log out and log back in (required for XQuartz)
2. Run: ./run.sh
"""
