#!/bin/zsh
# File: module/llm/llm.zsh
# Description: Script to handle Ctrl+Z key binding in Zsh with a simple "Thinking..." message replacing user input.

source "${MODULE_DIR}/log.zsh"
source "${MODULE_DIR}/utils.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/security.zsh"

# Function to handle Ctrl+Z
handle_ctrl_z() {
    log_debug_ex "Entering handle_ctrl_z function"
    if [[ -n $BUFFER ]]; then
        log_debug "Ctrl+Z pressed with buffer content: '$BUFFER'"

        # Save the current buffer and cursor position
        local saved_buffer=$BUFFER
        local saved_cursor=$CURSOR

        # Clear the suggestion and replace the current input with the "Thinking..." message
        _zsh_autosuggest_clear

        # Calculate number of lines for the user input
        local lines_count=$(((${#BUFFER} + $COLUMNS - 1) / $COLUMNS))
        
        # Build the "Thinking..." message
        local model_name="$OLLAMA_MODEL"
        local thinking_message="LLM $model_name Thinking..."

       # Clear the user input from the screen
        BUFFER=""  # Clear BUFFER to prevent conflicts with zle redisplay
        for ((i=0; i<lines_count; i++)); do
            zle -R ""  # Clear each line of the original input
        done

        # Move cursor to the beginning of the line and display the "Thinking..." message
        echo -ne "\r\033[K$thinking_message"

        # Send the input to the orchestrator
        log_debug_ex "Calling send_to_orchestrator with LLM prefix"
        local result=$(send_to_orchestrator "LLM:$saved_buffer")

        # Restore the prompt
        zle -R ""  # Clear the "Thinking..." message

        log_debug_ex "Received result from orchestrator: '$result'"
        if [[ -n $result ]]; then
            log_debug_ex "Updating BUFFER with orchestrator result"
            BUFFER="$result"
            CURSOR=${#BUFFER}
        else
            log_warning "No result received from orchestrator."
            BUFFER="$saved_buffer"
            CURSOR=$saved_cursor
        fi

        log_debug_ex "Triggering Zsh line editor redisplay"
        zle reset-prompt
        zle redisplay
    else
        log_debug "Ctrl+Z pressed with empty buffer."
        log_debug_ex "No action taken for empty buffer"
    fi
    log_debug_ex "Exiting handle_ctrl_z function"
}

# Create a new Zle widget
log_debug_ex "Creating Zle widget 'handle_ctrl_z'"
zle -N handle_ctrl_z
log_debug_ex "Zle widget 'handle_ctrl_z' created."

# Bind Ctrl+Z to the new widget
log_debug_ex "Setting key binding for Ctrl+Z"
bindkey '^Z' handle_ctrl_z
log_debug_ex "Ctrl+Z key binding set to 'handle_ctrl_z' widget."

log_debug_ex "Ctrl+Z handler script initialization complete"
