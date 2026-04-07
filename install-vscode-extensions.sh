#!/bin/bash
# install-vscode-extensions.sh
# Installs personal VS Code extensions in dev containers

echo "Installing personal VS Code extensions..."

CODE_CMD="${1:-${CODE_CLI:-code}}"

if ! "$CODE_CMD" --version >/dev/null 2>&1; then
    echo "VS Code CLI command '$CODE_CMD' is not usable, skipping extension installation"
    exit 0
fi

# Array of extension IDs you want to install
EXTENSIONS=(
    "github.vscode-pull-request-github" # https://github.com/Microsoft/vscode-pull-request-github
    "mk12.better-git-line-blame" #https://github.com/mk12/vscode-better-git-line-blame
    "GitHub.copilot-chat"
)

# Install each extension
for ext in "${EXTENSIONS[@]}"; do
    echo "Installing $ext..."
    "$CODE_CMD" --install-extension "$ext" --force
done

echo "Personal extensions installed!"
