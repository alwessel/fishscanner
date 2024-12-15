# FishScanner

A magical application that brings your fish drawings to life in a virtual ocean! Draw a fish on paper, scan it, and watch it swim around with other fish in a beautiful underwater world. 

This project is based on the wonderful work by [David Svitov](https://github.com/david-svitov/fishscanner), who created the original FishScanner. This version extends his creative vision to add support for HEIC images (from iPhones), live updates so you can add new fish without restarting the app, improve background detection, and make the experience even more delightful.

> Forked from [david-svitov/fishscanner](https://github.com/david-svitov/fishscanner)

![Run example](./images/img1.png)

> **🎉 2024 Update: Major Improvements!**
>
> A new and modernized FishScanner with:
> - **🚀 One-Click Setup**: Just run `./setup.sh` and you're ready to go
> - **📱 Apple Silicon Support**: Native support for M1/M2 Macs
> - **🎮 Better Graphics**: Enhanced OpenGL integration and rendering
> - **🔄 Modern Stack**: Updated to Python 3.11 and latest OpenCV
> - **🪄 Live Updates**: Fish appear instantly when you add photos - no restart needed!
> - **🛠 Improved Reliability**: Better error handling and troubleshooting
>
> [See full changelog](#2024-changes)

Bring your fish drawings to life in a virtual aquarium! This project is inspired by this [video](https://www.youtube.com/watch?v=ILrr8vToR9Y&feature=emb_logo) from Workinman Interactive LLC.

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
   - Supported formats: JPG and HEIC (iPhone photos)
   - The fish will appear automatically in the ocean!
   - Run the app: `./run.sh`

## 2024 Changes

### New Features
- **One-Click Setup**: Added setup and run scripts for easy installation
- **Modern Dependencies**: Updated to Python 3.11 and latest OpenCV
- **Better Graphics**: 
  - Enhanced OpenGL integration with proper GLUT initialization
  - Fixed vertex array handling for better hardware support
- **Apple Silicon Support**: Added compatibility for M1/M2 Macs
- **Live File Watching**: 
  - Fish appear instantly when you add photos to the folder
  - No need to restart the app when adding new fish
  - Uses efficient filesystem events for minimal system impact
- **Improved Error Handling**: Better error messages and troubleshooting guides

### Technical Improvements
- Modernized OpenGL context initialization
- Updated dependency specifications for better compatibility
- Improved state management in rendering pipeline
- Enhanced graphics performance and stability
- Added comprehensive troubleshooting documentation
- Efficient file system monitoring using native events

## Recent Improvements

### Enhanced Fish Detection and AR Marker Handling
- Improved detection of colored edges, particularly for red tones near AR markers
- Reduced AR marker interference with fish illustrations through:
  - Smaller marker detection areas (110px vs 130px)
  - Added 15px padding around markers
  - Gradient-based transitions to preserve fish details
- Enhanced edge preservation using:
  - Morphological gradient detection
  - Multi-stage mask combination
  - Gaussian-blurred transitions
- Better color handling:
  - Increased weighting for red channel (60% vs standard 30%)
  - Improved grayscale conversion for better edge detection

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
brew install glfw python@3.11 freeglut
brew install --cask xquartz
```

2. Set up Python:
```bash
python3.11 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
```

3. Configure environment:
```bash
echo "export DISPLAY=:0" >> ~/.zshrc
# Log out and log back in
```

## Project Structure

- `ocean/patterns/`: Fish templates for printing
- `photos/`: Place your scanned fish drawings here
- `engine/`: Core application code
- `ocean/`: Example aquarium implementation