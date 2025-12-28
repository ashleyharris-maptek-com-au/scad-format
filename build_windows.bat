@echo off
REM Windows build script for scad-format
REM Creates scad-format.exe and packages it into a zip file

setlocal enabledelayedexpansion

echo === Building scad-format for Windows ===

REM Check if pyinstaller is available
python -c "import PyInstaller" 2>nul
if errorlevel 1 (
    echo PyInstaller not found. Installing...
    pip install pyinstaller>=6.0.0
)

REM Get version from pyproject.toml
for /f "tokens=2 delims==" %%a in ('findstr /C:"version = " pyproject.toml') do (
    set VERSION=%%a
    set VERSION=!VERSION:"=!
    set VERSION=!VERSION: =!
)
echo Building version: %VERSION%

REM Clean previous builds
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build

REM Build the executable
echo Building executable...
python -m PyInstaller ^
    --onefile ^
    --name scad-format ^
    --console ^
    --clean ^
    scad-format.py

if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

REM Create distribution directory
set DIST_DIR=dist\scad-format-%VERSION%-windows
mkdir "%DIST_DIR%"

REM Copy files
copy dist\scad-format.exe "%DIST_DIR%\"
copy README.md "%DIST_DIR%\"
copy LICENSE "%DIST_DIR%\" 2>nul
copy .scad-format "%DIST_DIR%\example.scad-format"

REM Create zip file
echo Creating zip file...
cd dist
powershell -Command "Compress-Archive -Path 'scad-format-%VERSION%-windows' -DestinationPath 'scad-format-%VERSION%-windows.zip' -Force"
cd ..

echo.
echo === Build complete ===
echo Executable: dist\scad-format.exe
echo Zip file: dist\scad-format-%VERSION%-windows.zip

endlocal
