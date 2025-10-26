# FishScanner

A magical application that brings your fish drawings to life in a virtual ocean! Draw a fish on paper, scan it, and watch it swim around with other fish in a beautiful underwater world. 

This project is based on the wonderful work by [David Svitov](https://github.com/david-svitov/fishscanner), who created the original FishScanner and the improved version of [jharsono](https://github.com/jharsono/fishscanner) that extends his creative vision to add support for HEIC images (from iPhones), live updates so you can add new fish without restarting the app, improve background detection, and make the experience even more delightful.

I updated the scripts to run on windows 11 with Python 3.11

> [jharsono](https://github.com/jharsono/fishscanner)


![Run example](./images/img1.png)

## Installation (windows)

```cmd
git clone https://github.com/alwessel/fishscanner.git
cd fishscanner
# this expecteds Python 3.11 to be installed already.
./setup.cmd

```

## Installation (macOS)

```bash
git clone https://github.com/jharsono/fishscanner.git
cd fishscanner
./setup.sh

# Important: Log out and log back in after installation
```

## How to Use

1. Print a template
   - Choose any template from `ocean/patterns/fish_1.pdf` through `fish_5.pdf`
   - Each template has special markers in the corners for detection
   ![Scan example](./images/img2.jpg)

2. Draw your fish
   - Use any colors or designs you like
   - Keep your drawing inside the marked area
   - Make sure the corner markers stay visible

3. Add your fish
   - Take a photo of your drawing and save it to the `photos` folder
   - Supported formats: JPG, PNG and HEIC (iPhone photos)
   - The fish will appear automatically in the ocean!
   - Run the app: `./run.sh` or `./run.bat` (on Windows)

## Controls

- **Arrow Keys**: Use left and right arrow keys to switch between different ocean scenes
- **ESC**: Exit the application

## 2024 Changes

### Core Improvements
- **Enhanced Fish Detection**:
  - Improved edge preservation using gradient-based detection
  - Better handling of red ink details (60% weighting vs standard 30%)
  - Optimized AR marker boundaries with padding and smooth transitions
  - Reduced marker interference using smaller detection areas (110px)

### Technical Updates
- **Modernized Graphics Pipeline**:
  - Enhanced OpenGL integration with proper GLUT initialization
  - Improved state management and vertex array handling
  - Better performance with efficient filesystem monitoring
  - Updated dependencies for cross-platform compatibility

### User Experience
- **Streamlined Setup**:
  - One-click installation script
  - Automatic dependency management
  - Native Apple Silicon support
- **Real-time Updates**:
  - Instant fish appearance when photos are added
  - No app restart needed for new additions
  - Comprehensive error handling and troubleshooting

## Platform Compatibility

FishScanner is compatible with:
- macOS (both Apple Silicon and Intel)
- Windows
- Linux

### Platform-Specific Notes

#### macOS
- Works on both Apple Silicon (M1/M2) and Intel processors
- No additional configuration needed

#### Windows
- Requires OpenGL drivers (typically pre-installed)
- May need to install Microsoft Visual C++ Redistributable if not already present

#### Linux
- Requires OpenGL development libraries
  ```bash
  # Ubuntu/Debian
  sudo apt-get install python3-opengl
  sudo apt-get install libglfw3
  ```

All core dependencies (numpy, OpenCV, PyOpenGL, etc.) are cross-platform compatible.

## Troubleshooting

Having issues? Check these common solutions:

1. **First time setup fails**
   - Make sure you're connected to the internet
   - Try running the commands in the [Manual Setup](#manual-setup) section

2. **App doesn't start**
   - Make sure you logged out and back in after installation
   - Try running `open -a XQuartz` manually

For detailed solutions to these and other issues, see our [Troubleshooting Guide](TROUBLESHOOTING.md).

## Manual Setup

If you prefer manual installation or the setup script fails:

1. Install system dependencies:
```bash
brew install glfw python@3.12 freeglut
brew install --cask xquartz
```

2. Set up Python:
```bash
python3.12 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
```

3. Configure environment:
```bash
# for mac os
echo "export DISPLAY=:0" >> ~/.zshrc
# for ubuntu on wsl
echo "export PYOPENGL_PLATFORM=glx" >> ~/.bashrc
# Log out and log back in
```

4. Start the main script:
```bash
echo Running FishScanner... press ESC to stop.
python main_ocean.py
```


## Project Structure

- `ocean/patterns/`: Fish templates for printing
- `photos/`: Place your scanned fish drawings here
- `engine/`: Core application code
- `ocean/`: Example aquarium implementation