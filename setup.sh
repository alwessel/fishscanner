#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🐠 Setting up FishScanner..."

# Check if Homebrew is installed
if ! command_exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew is already installed"
fi

# Install system dependencies using Homebrew
echo "Installing system dependencies..."
brew install glfw python@3.11 freeglut

# Check if XQuartz is installed
if ! command_exists xquartz; then
    echo "Installing XQuartz..."
    brew install --cask xquartz
    echo "⚠️  Important: You'll need to log out and log back in for XQuartz to work properly"
else
    echo "✅ XQuartz is already installed"
fi

# Create and activate virtual environment
echo "Setting up Python virtual environment..."
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "Installing Python packages..."
python3 -m pip install -r requirements.txt

# Optional: Install PyOpenGL-accelerate for better performance
echo "Installing optional performance enhancement..."
python3 -m pip install PyOpenGL-accelerate || echo "⚠️  PyOpenGL-accelerate installation failed (this is optional)"

# Set up DISPLAY environment variable
echo "export DISPLAY=:0" >> ~/.zshrc
echo "export DISPLAY=:0" >> ~/.bashrc

echo """
✨ Setup complete! ✨

To run FishScanner:
1. Open a new terminal or run: source ~/.zshrc
2. Start XQuartz: open -a XQuartz
3. Activate the virtual environment: source venv/bin/activate
4. Run: python3 main_ocean.py

Enjoy bringing your fish drawings to life! 🐠
"""
