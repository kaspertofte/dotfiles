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
