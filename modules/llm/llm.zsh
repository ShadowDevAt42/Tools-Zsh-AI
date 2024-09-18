#!/bin/zsh

# Function to handle Ctrl+Z
handle_ctrl_z() {
    if [[ -n $BUFFER ]]; then
        local result=$(send_to_orchestrator "LLM:$BUFFER")
        BUFFER="$result"
        zle redisplay
    fi
}

# Create a new Zle widget
zle -N handle_ctrl_z

# Bind Ctrl+Z to the new widget
bindkey '^Z' handle_ctrl_z