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
MIN_DISK_SPACE=500000000  # 500MB
MIN_MEMORY=1000000000     # 1GB
PYTHON_VERSION="3.11"
BREW_PACKAGES=("glfw" "python@${PYTHON_VERSION}" "freeglut")
REQUIRED_DIRS=("photos" "ocean/patterns")

# Progress tracking
total_steps=8
current_step=0

# Logging
LOG_FILE="setup.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Function to show progress
show_progress() {
    current_step=$((current_step + 1))
    echo -e "${GREEN}[$current_step/$total_steps]${NC} $1"
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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if XQuartz is installed
xquartz_installed() {
    [ -d "/Applications/XQuartz.app" ]
}

# Function to check system requirements
check_system_requirements() {
    show_progress "Checking system requirements..."
    
    # Check OS
    if [[ "$(uname)" != "Darwin" ]]; then
        error_exit "This script is only for macOS"
    fi
    
    # Check disk space
    available_space=$(df -k . | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$MIN_DISK_SPACE" ]; then
        error_exit "Not enough disk space (need at least 500MB)"
    fi
    
    # Check memory
    available_memory=$(sysctl hw.memsize | awk '{print $2}')
    if [ "$available_memory" -lt "$MIN_MEMORY" ]; then
        error_exit "Not enough memory (need at least 1GB)"
    fi
    
    # Check network connectivity
    if ! ping -c 1 github.com &> /dev/null; then
        error_exit "No internet connection"
    fi
    
    # Check required directories
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            error_exit "Required directory '$dir' not found"
        fi
    done
}

# Function to setup shell profile
setup_shell_profile() {
    show_progress "Setting up shell profile..."
    
    local profile="$HOME/.zshrc"
    local updated=false
    
    # Create profile if it doesn't exist
    touch "$profile"
    
    # Add DISPLAY export if needed
    if ! grep -q "export DISPLAY=:0" "$profile"; then
        echo "export DISPLAY=:0" >> "$profile"
        updated=true
    fi
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == 'arm64' ]] && ! grep -q "opt/homebrew" "$profile"; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$profile"
        updated=true
    fi
    
    if [ "$updated" = true ]; then
        show_warning "Shell profile updated. You'll need to restart your terminal or run: source $profile"
    fi
}

# Function to install/update Homebrew
setup_homebrew() {
    show_progress "Setting up Homebrew..."
    
    if ! command_exists brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Failed to install Homebrew"
        
        if [[ $(uname -m) == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "Updating Homebrew..."
        brew update || show_warning "Failed to update Homebrew"
    fi
}

# Function to install system dependencies
install_dependencies() {
    show_progress "Installing system dependencies..."
    
    # Install Homebrew packages
    for package in "${BREW_PACKAGES[@]}"; do
        echo -e "${BLUE}Installing $package...${NC}"
        brew install "$package" || error_exit "Failed to install $package"
    done
    
    # Install XQuartz if needed
    if ! xquartz_installed; then
        echo "Installing XQuartz..."
        brew install --cask xquartz || error_exit "Failed to install XQuartz"
        show_warning "You'll need to log out and log back in for XQuartz to work properly"
    fi
}

# Function to setup Python environment
setup_python() {
    show_progress "Setting up Python environment..."
    
    # Verify Python version
    if ! command_exists "python${PYTHON_VERSION}"; then
        error_exit "Python ${PYTHON_VERSION} not found. Try running: brew link python@${PYTHON_VERSION}"
    fi
    
    local python_cmd="python${PYTHON_VERSION}"
    local version=$($python_cmd -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if [[ "$version" != "${PYTHON_VERSION}" ]]; then
        error_exit "Wrong Python version: $version (expected ${PYTHON_VERSION})"
    fi
    
    # Remove existing venv if present
    if [ -d "venv" ]; then
        echo "Removing existing virtual environment..."
        rm -rf venv
    fi
    
    # Create and activate virtual environment
    echo "Creating virtual environment..."
    $python_cmd -m venv venv || error_exit "Failed to create virtual environment"
    
    # Activate virtual environment
    source venv/bin/activate || error_exit "Failed to activate virtual environment"
    
    # Upgrade pip
    echo "Upgrading pip..."
    pip install --upgrade pip || show_warning "Failed to upgrade pip"
    
    # Install Python dependencies
    echo "Installing Python dependencies..."
    pip install -r requirements.txt || error_exit "Failed to install Python dependencies"
}

# Function to verify installation
verify_installation() {
    show_progress "Verifying installation..."
    
    # Check if virtual environment is active
    if [[ "$VIRTUAL_ENV" != *"venv"* ]]; then
        error_exit "Virtual environment not active"
    fi
    
    # Check if all required packages are installed
    python -c "import numpy, cv2, OpenGL, glfw" || error_exit "Missing required Python packages"
    
    # Check if XQuartz is running
    if ! pgrep -f "XQuartz" >/dev/null && ! pgrep -f "Xorg" >/dev/null; then
        show_warning "XQuartz is not running. You may need to log out and log back in"
    fi
}

# Main installation process
main() {
    echo -e "${BLUE}🐠 Setting up FishScanner...${NC}"
    echo "Installation log will be saved to $LOG_FILE"
    
    # Clear existing log
    > "$LOG_FILE"
    
    # Run installation steps
    check_system_requirements
    setup_shell_profile
    setup_homebrew
    install_dependencies
    setup_python
    verify_installation
    
    # Final instructions
    show_progress "Setup complete!"
    echo -e "${GREEN}✨ FishScanner has been successfully installed!${NC}"
    echo
    echo "To start using FishScanner:"
    echo "1. Log out and log back in (required for XQuartz)"
    echo "2. Run ./run.sh to start the application"
    echo
    echo "For troubleshooting, check:"
    echo "- Setup log: $LOG_FILE"
    echo "- Troubleshooting guide: TROUBLESHOOTING.md"
}

# Run main installation
main
