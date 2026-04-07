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

# Locate VS Code CLI even when PATH is not fully initialized yet.
find_code_cli() {
    if command -v code >/dev/null 2>&1; then
        command -v code
        return 0
    fi
    local code_path

    # Common remote containers location.
    code_path=$(find /vscode/vscode-server/bin -maxdepth 5 -type f -path '*/bin/remote-cli/code' 2>/dev/null | head -n 1)
    if [ -n "$code_path" ]; then
        echo "$code_path"
        return 0
    fi

    # Fallback location under the user home symlink tree.
    code_path=$(find "$HOME/.vscode-server/bin" -maxdepth 5 -type f -name code 2>/dev/null | head -n 1)
    if [ -n "$code_path" ]; then
        echo "$code_path"
        return 0
    fi

    return 1
}

# try to find the code CLI for up to 30 seconds, as it may not be available immediately when the container starts
CODE_CLI=""
for _ in {1..30}; do
    if CODE_CLI=$(find_code_cli); then
        break
    fi
    sleep 1
done

if [ -n "$CODE_CLI" ]; then
    echo "VS Code CLI found at $CODE_CLI, installing extensions..."
    bash ~/dotfiles/install-vscode-extensions.sh "$CODE_CLI"
else
    echo "VS Code CLI not found after waiting, skipping extension installation"
fi
