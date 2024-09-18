#!/bin/zsh

# Description:
#   Script to handle Ctrl+Z key binding in Zsh.
#   When Ctrl+Z is pressed, it sends the current command buffer to the orchestrator
#   and replaces the buffer with the result.

# Source necessary
source "${MODULE_DIR}/log.zsh"
source "${MODULE_DIR}/utils.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/security.zsh"

# Function to handle Ctrl+Z
handle_ctrl_z() {
    # Handles the Ctrl+Z key binding.
    #
    # If the command buffer is not empty, sends it to the orchestrator
    # and replaces the buffer with the result.
    #
    # Adds detailed debug logs for advanced debugging.

    if [[ -n $BUFFER ]]; then
        log_debug "Ctrl+Z pressed with buffer content: '$BUFFER'"
        log_debug_ex "Sending buffer content to orchestrator for processing."

        # Sanitize the input before sending
        # local sanitized_input=$(sanitize_input "$BUFFER")
        #log_debug_ex "Sanitized input: '$sanitized_input'"

        # Send the input to the orchestrator
        local result=$(send_to_orchestrator "LLM:$BUFFER")
        log_debug_ex "Received result from orchestrator: '$result'"

        if [[ -n $result ]]; then
            BUFFER="$result"
            zle redisplay
            log_debug_ex "Command buffer updated with orchestrator result."
        else
            log_warning "No result received from orchestrator."
        fi
    else
        log_debug "Ctrl+Z pressed with empty buffer."
    fi
}

# Create a new Zle widget
zle -N handle_ctrl_z
log_debug_ex "Zle widget 'handle_ctrl_z' created."

# Bind Ctrl+Z to the new widget
bindkey '^Z' handle_ctrl_z
log_debug_ex "Ctrl+Z key binding set to 'handle_ctrl_z' widget."
