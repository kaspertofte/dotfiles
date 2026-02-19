#!/bin/bash

# Remove old bashrc symlink if it exists and restore from backup or create new
if [ -L ~/.bashrc ]; then
    # Create a minimal bashrc if none exists
    if [ ! -f ~/.bashrc ]; then
        touch ~/.bashrc
    fi
fi

# Symlink dotfiles
ln -sf ~/dotfiles/bash_aliases ~/.bash_aliases

# Remove old gitconfig symlink if it exists
if [ -L ~/.gitconfig ]; then
    rm ~/.gitconfig
    touch ~/.gitconfig
fi

# Include gitconfig in ~/.gitconfig if not already present
if ! grep -q "path = ~/dotfiles/gitconfig" ~/.gitconfig 2>/dev/null; then
    echo "" >> ~/.gitconfig
    echo "[include]" >> ~/.gitconfig
    echo "    path = ~/dotfiles/gitconfig" >> ~/.gitconfig
fi

# Append source line to existing .bashrc if not already present
if ! grep -q "source ~/dotfiles/bashrc" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Source personal dotfiles" >> ~/.bashrc
    echo "source ~/dotfiles/bashrc" >> ~/.bashrc
fi

# Install VS Code extensions if code CLI is available
if command -v code &> /dev/null; then
    echo "VS Code CLI found, installing extensions..."
    bash "$DOTFILES_DIR/install-vscode-extensions.sh"
else
    echo "VS Code CLI not found, skipping extension installation"
fi
