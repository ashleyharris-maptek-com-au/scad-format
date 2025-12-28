#!/bin/bash
# Linux install script for scad-format
# Usage: sudo ./install_linux.sh [--uninstall]

set -e

INSTALL_DIR="/usr/local/lib/scad-format"
BIN_LINK="/usr/local/bin/scad-format"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        exit 1
    fi
}

# Check Python installation
check_python() {
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    else
        print_error "Python is not installed. Please install Python 3.8 or later."
        exit 1
    fi
    
    # Check Python version
    VERSION=$($PYTHON_CMD -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    MAJOR=$(echo $VERSION | cut -d. -f1)
    MINOR=$(echo $VERSION | cut -d. -f2)
    
    if [ "$MAJOR" -lt 3 ] || ([ "$MAJOR" -eq 3 ] && [ "$MINOR" -lt 8 ]); then
        print_error "Python 3.8 or later is required. Found: Python $VERSION"
        exit 1
    fi
    
    print_status "Found Python $VERSION"
}

# Uninstall
uninstall() {
    print_status "Uninstalling scad-format..."
    
    if [ -L "$BIN_LINK" ]; then
        rm -f "$BIN_LINK"
        print_status "Removed symlink: $BIN_LINK"
    fi
    
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        print_status "Removed directory: $INSTALL_DIR"
    fi
    
    print_status "Uninstall complete!"
}

# Install
install() {
    print_status "Installing scad-format..."
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check required files exist
    if [ ! -f "$SCRIPT_DIR/scad-format.py" ]; then
        print_error "scad-format.py not found in $SCRIPT_DIR"
        exit 1
    fi
    
    if [ ! -d "$SCRIPT_DIR/scad_format" ]; then
        print_error "scad_format module not found in $SCRIPT_DIR"
        exit 1
    fi
    
    # Remove old installation if exists
    if [ -d "$INSTALL_DIR" ] || [ -L "$BIN_LINK" ]; then
        print_warning "Previous installation found. Removing..."
        uninstall
    fi
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy files
    print_status "Copying files to $INSTALL_DIR..."
    cp "$SCRIPT_DIR/scad-format.py" "$INSTALL_DIR/"
    cp -r "$SCRIPT_DIR/scad_format" "$INSTALL_DIR/"
    
    # Copy optional files
    [ -f "$SCRIPT_DIR/README.md" ] && cp "$SCRIPT_DIR/README.md" "$INSTALL_DIR/"
    [ -f "$SCRIPT_DIR/LICENSE" ] && cp "$SCRIPT_DIR/LICENSE" "$INSTALL_DIR/"
    [ -f "$SCRIPT_DIR/.scad-format" ] && cp "$SCRIPT_DIR/.scad-format" "$INSTALL_DIR/example.scad-format"
    
    # Set permissions
    print_status "Setting permissions..."
    chmod +x "$INSTALL_DIR/scad-format.py"
    chmod -R a+r "$INSTALL_DIR"
    
    # Create symlink
    print_status "Creating symlink: $BIN_LINK"
    ln -s "$INSTALL_DIR/scad-format.py" "$BIN_LINK"
    
    # Verify installation
    if command -v scad-format &> /dev/null; then
        print_status "Installation complete!"
        echo ""
        echo "You can now use scad-format from anywhere:"
        echo "  scad-format --help"
        echo "  scad-format -i myfile.scad"
    else
        print_warning "Installation complete, but 'scad-format' not found in PATH."
        print_warning "You may need to add /usr/local/bin to your PATH."
    fi
}

# Main
check_root

case "${1:-}" in
    --uninstall|-u)
        uninstall
        ;;
    --help|-h)
        echo "Usage: sudo $0 [--uninstall]"
        echo ""
        echo "Options:"
        echo "  --uninstall, -u    Remove scad-format from the system"
        echo "  --help, -h         Show this help message"
        ;;
    *)
        check_python
        install
        ;;
esac
