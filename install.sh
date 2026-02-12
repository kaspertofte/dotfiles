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
ln -sf ~/dotfiles/gitconfig ~/.gitconfig

# Append source line to existing .bashrc if not already present
if ! grep -q "source ~/dotfiles/bashrc" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Source personal dotfiles" >> ~/.bashrc
    echo "source ~/dotfiles/bashrc" >> ~/.bashrc
fi
