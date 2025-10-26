@echo off

echo.
echo === FishScanner Windows Setup ===
echo.

:: Check if Python 3.12 is available
echo Checking Python 3.12 installation...
set PYTHON_CMD=python3.12
%PYTHON_CMD% --version >nul 2>&1
if errorlevel 1 (
    echo Python 3.12 not found, trying 'py -3.12'...
    set PYTHON_CMD=py -3.12
    %PYTHON_CMD% --version >nul 2>&1
    if errorlevel 1 (
        echo Python 3.12 not found, trying default python...
    )
)

:: Show Python version
for /f "tokens=2" %%i in ('%PYTHON_CMD% --version 2^>^&1') do set CURRENT_VERSION=%%i
echo Using Python version: %CURRENT_VERSION%

:: Remove existing venv if present
if exist venv (
    echo Removing existing virtual environment...
    rmdir /s /q venv
)

:: Create virtual environment with Python 3.12
echo Creating virtual environment with Python 3.12...
%PYTHON_CMD% -m venv venv
if errorlevel 1 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)
:: sleep 1 to wait for venv script creation
timeout /t 1 >nul

:: Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)

:: Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

:: Install requirements
echo Installing requirements from requirements.txt...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install requirements from requirements.txt
    pause
    exit /b 1
)

:: Verify installation
echo Verifying installation...
python -c "import numpy; print('NumPy version:', numpy.__version__)"
python -c "import cv2; print('OpenCV version:', cv2.__version__)"
python -c "import OpenGL; print('PyOpenGL imported successfully')"
python -c "import glfw; print('GLFW version:', glfw.get_version_string())"
python -c "import watchdog; print('Watchdog imported successfully')"

:: Success message
echo.
echo === Setup Complete! ===
echo.
echo FishScanner has been successfully set up!
echo.
echo To run the application start: run.bat
echo.
pause