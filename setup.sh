#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting setup..."

# --- OS Detection and Dependency Installation ---
OS="$(uname -s)"

case "$OS" in
    Linux*)
        echo "Detected Linux OS."
        if command -v apt-get &> /dev/null; then
            echo "Found apt-get. Updating packages and installing dependencies..."
            sudo apt-get update
            sudo apt-get install -y tmux neovim
        elif command -v dnf &> /dev/null; then
            echo "Found dnf. Installing dependencies..."
            sudo dnf install -y tmux neovim
        else
            echo "Could not find a supported package manager (apt or dnf). Please install tmux and neovim manually."
            exit 1
        fi
        echo "NOTE: For Ghostty, manual installation is required on Linux."
        echo "Please visit https://github.com/ghostty-org/ghostty for instructions."
        ;;
    Darwin*)
        echo "Detected macOS. Using Homebrew..."
        # Check for Homebrew and install if it's not found.
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        # Install tmux, neovim, and ghostty using Homebrew.
        echo "Installing tmux, neovim, and ghostty..."
        brew install tmux neovim ghostty
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac


# --- Configuration File Copying ---
echo "Copying configuration files..."

# Get the absolute path of the directory where the script is located.
# This allows the script to be run from any directory.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Create target directories if they don't exist.
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/nvim

# Copy the configuration files from the repository to their respective locations.
# The -v flag on cp makes it verbose, showing what's being copied.
cp -v "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
cp -v "$SCRIPT_DIR/.config/ghostty/config" ~/.config/ghostty/config
cp -rv "$SCRIPT_DIR/.config/nvim/" ~/.config/nvim/

echo "Setup complete! Please restart your terminal for all changes to take effect."
