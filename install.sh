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

# Returns success only when the CLI is actually usable for extension commands.
is_cli_usable() {
    local cli="$1"
    local output

    output=$("$cli" --list-extensions 2>&1 || true)
    if echo "$output" | grep -q "Command is only available in WSL or inside a Visual Studio Code terminal."; then
        return 1
    fi

    return 0
}

find_code_server_cli() {
    local cli
    cli=$(ls -1d /vscode/vscode-server/bin/linux-x64/*/bin/code-server 2>/dev/null | sort | tail -n 1)
    if [ -n "$cli" ]; then
        echo "$cli"
        return 0
    fi

    return 1
}

# Wait for a usable `code` command during startup.
CODE_CLI=""
for _ in {1..60}; do
    if command -v code >/dev/null 2>&1; then
        CODE_CLI=$(command -v code)
        if is_cli_usable "$CODE_CLI"; then
            break
        fi
        CODE_CLI=""
    fi
    sleep 1
done

if [ -n "$CODE_CLI" ]; then
    echo "Usable VS Code CLI found at $CODE_CLI, installing extensions..."
    bash ~/dotfiles/install-vscode-extensions.sh "$CODE_CLI"
elif CODE_SERVER_CLI=$(find_code_server_cli); then
    echo "Falling back to code-server CLI at $CODE_SERVER_CLI for extension installation..."
    bash ~/dotfiles/install-vscode-extensions.sh "$CODE_SERVER_CLI"
else
    echo "No usable VS Code CLI found after waiting, skipping extension installation"
fi
