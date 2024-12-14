# FishScanner

[![Youtube video demonstration](https://img.youtube.com/vi/ClF8CrXzJ8k/0.jpg)](https://www.youtube.com/watch?v=ClF8CrXzJ8k)

This is an open-source project inspired by this [video](https://www.youtube.com/watch?v=ILrr8vToR9Y&feature=emb_logo) from  Workinman Interactive LLC.

This repository allows you to build your own aquarium in which you can bring to life your drawings of fish.

## 2024 Update: Enhanced Version

This is an upgraded version of the original FishScanner application, featuring several improvements and modernizations:

- **Updated Dependencies**: Now compatible with Python 3.11 and latest OpenCV
- **Improved OpenGL Integration**: 
  - Enhanced graphics rendering with proper GLUT initialization
  - Better compatibility with different OpenGL implementations
  - Fixed vertex array handling for broader hardware support
- **M1/M2 Mac Support**: Added compatibility for Apple Silicon processors
- **Modern Package Management**: Updated dependency specifications for better compatibility

### Dependencies and installation

Source code in this repository requires Python 3.11 and has been tested on macOS.

#### Prerequisites

On macOS, you'll need to install some system dependencies first:

1. Install XQuartz (required for OpenGL support):
   - Download and install XQuartz from [https://www.xquartz.org/](https://www.xquartz.org/)
   - After installation, **log out and log back in** to your Mac (or restart)

2. Install other dependencies using Homebrew:
```sh
brew install glfw python@3.11 freeglut
```

#### Python Setup

1. Create a new virtual environment:
```sh
# Make sure you're in the fishscanner directory
python3.11 -m venv venv
```

2. Activate the virtual environment:
```sh
source venv/bin/activate
```

3. Install the required Python packages:
```sh
# Make sure your virtual environment is activated (you should see (venv) in your terminal)
python3 -m pip install -r requirements.txt
```

> **Note**: Always make sure your virtual environment is activated when running the application. You can tell it's activated when you see `(venv)` at the start of your terminal prompt.

> **Optional Performance Enhancement**: If you want better OpenGL performance, you can try installing `PyOpenGL-accelerate` by running:
> ```sh
> python3 -m pip install PyOpenGL-accelerate
> ```
> Note that this package requires a C compiler and may not build successfully on all systems.

### How to use

1. First, ensure XQuartz is running:
```sh
# Start XQuartz (required for OpenGL)
open -a XQuartz

# Set the display environment variable
export DISPLAY=:0
```

2. Print `./ocean/patterns/fish_1.pdf` and decorate your fish:
    ![Scan example](./images/img2.jpg)

3. Take a photo of your fish and put it in the `./photos` folder

4. Run the demo:
    ```sh
    python3 main_ocean.py
    ``` 
    ![Run example](./images/img1.png)

### Troubleshooting

If you encounter any issues:

1. **OpenGL/GLUT Errors**:
   - Make sure you have installed all system dependencies using the `brew` commands above
   - If you see segmentation faults, try reinstalling freeglut: `brew reinstall freeglut`
   - For rendering issues, ensure your graphics drivers are up to date
   - If you see "failed to open display" error:
     - Make sure XQuartz is installed and running (`open -a XQuartz`)
     - Set the display variable: `export DISPLAY=:0`
     - If the error persists, try logging out and back in to your Mac
     - You can also try: `export DISPLAY=:0.0` or `export DISPLAY=localhost:0`

2. **Python/Package Issues**:
   - Ensure you're using Python 3.11: `python3 --version`
   - Try reinstalling packages: `pip install -r requirements.txt --force-reinstall`
   - If using M1/M2 Mac, you might need to install packages with specific architecture: `pip install --platform=macosx_11_0_arm64`

3. **Camera Access**:
   - Make sure to grant camera permissions to the terminal/IDE you're using
   - Try different camera IDs if the default doesn't work (modify `camera_id` parameter in the code)

### Project structure

All core code contains in the `./engine` folder.

You can create your own aquarium using code example from the `./ocean` folder.