# Load bash completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Source bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Git completion and auto-aliases
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

# Create g<alias> bash aliases for all git config aliases with tab completion
for al in $(git --list-cmds=alias); do
    alias g$al="git $al"
    
    complete_func=_git_$(__git_aliased_command $al)
    function_exists $complete_func && __git_complete g$al $complete_func
done

# Custom prompt with git branch and status
git_prompt() {
    # Quick check if we're in a git repo
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        local status=""
        # Faster dirty check - only checks index vs working tree
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            status="*"
        fi
        echo " ($branch$status)"
    fi
}

# Virtual environment indicator
venv_prompt() {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "($(basename $VIRTUAL_ENV)) "
    fi
}

# Prompt: (venv) user@host:path (branch*) $
# Colors: cyan venv, green user@host, blue path, yellow branch, red * for dirty
PS1='\[\033[01;36m\]$(venv_prompt)\[\033[00m\]'
PS1=$PS1'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
PS1=$PS1'\[\033[01;33m\]$(git_prompt)\[\033[00m\]\$ '
