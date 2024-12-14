# Troubleshooting Guide

This guide covers common issues you might encounter while setting up and running FishScanner.

## Installation Issues

### Homebrew Installation Fails
```
Error: Failed to install homebrew
```
**Solutions:**
1. Check your internet connection
2. Run `xcode-select --install` to ensure developer tools are installed
3. Try the manual installation commands from the [Manual Setup](README.md#manual-setup) section

### Python Installation Issues
```
Error: python@3.11 is already installed
```
**Solutions:**
1. Try unlinking and relinking Python:
```bash
brew unlink python@3.11
brew link python@3.11
```
2. Verify Python installation:
```bash
python3.11 --version
```

### XQuartz Issues
```
Error: failed to open display
```
**Solutions:**
1. Make sure you've logged out and back in after installing XQuartz
2. Try these commands:
```bash
open -a XQuartz
export DISPLAY=:0
```
3. Alternative display settings:
```bash
export DISPLAY=:0.0
# or
export DISPLAY=localhost:0
```

## Runtime Issues

### OpenGL/GLUT Errors

#### Segmentation Faults
**Solutions:**
1. Reinstall freeglut:
```bash
brew reinstall freeglut
```
2. Make sure XQuartz is running before starting the app
3. Try running the app with the included script: `./run.sh`

#### Graphics Driver Issues
**Symptoms:** Black screen, graphical glitches, or crashes
**Solutions:**
1. Update your system software
2. Reinstall OpenGL dependencies:
```bash
brew reinstall glfw
```

### Camera Problems

#### Camera Not Found
```
Error: Camera device not available
```
**Solutions:**
1. Grant camera permissions:
   - System Settings → Privacy & Security → Camera
   - Enable for Terminal/IDE you're using
2. Try different camera IDs:
   - Open `main_ocean.py`
   - Change `camera_id` parameter (try 0, 1, or 2)

#### Poor Fish Detection
**Solutions:**
1. Ensure good lighting conditions
2. Keep corner markers clearly visible
3. Hold the paper steady and flat
4. Make sure the entire template is visible in the camera

### Virtual Environment Issues

#### Activation Fails
```
Error: cannot activate virtual environment
```
**Solutions:**
1. Recreate the virtual environment:
```bash
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
```
2. Install dependencies again:
```bash
python3 -m pip install -r requirements.txt
```

#### Missing Dependencies
```
ModuleNotFoundError: No module named '...'
```
**Solutions:**
1. Make sure virtual environment is activated (you should see `(venv)` in terminal)
2. Reinstall dependencies:
```bash
python3 -m pip install -r requirements.txt --force-reinstall
```

## Performance Optimization

### Slow Performance
**Solutions:**
1. Install optional performance package:
```bash
python3 -m pip install PyOpenGL-accelerate
```
2. Close other resource-intensive applications
3. Ensure good lighting for better fish detection

### Memory Issues
**Solutions:**
1. Remove old photos from the `photos` folder
2. Restart the application
3. Make sure you have enough free disk space

## Still Having Problems?

If you're still experiencing issues:
1. Check the [issues page](https://github.com/jharsono/fishscanner/issues) for similar problems
2. Create a new issue with:
   - Description of the problem
   - Steps to reproduce
   - Error messages
   - Your system information (OS version, Python version)
