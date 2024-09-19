#!/bin/zsh
# File: module/llm/llm.zsh

# Description:
# Script to handle Ctrl+Z key binding in Zsh.
# When Ctrl+Z is pressed, it sends the current command buffer to the orchestrator
# and replaces the buffer with the result.

# Source necessary modules
source "${MODULE_DIR}/log.zsh"
source "${MODULE_DIR}/utils.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/security.zsh"

# Function to handle Ctrl+Z
handle_ctrl_z() {
    # Handles the Ctrl+Z key binding.
    #
    # This function is triggered when Ctrl+Z is pressed in the Zsh shell.
    # It processes the current command buffer, sends it to the orchestrator
    # for processing (if not empty), and updates the buffer with the result.
    #
    # Global variables:
    #   BUFFER - The current command line buffer in Zsh
    #
    # Side effects:
    #   - Modifies the BUFFER variable
    #   - Triggers a redisplay of the Zsh line editor
    #   - Logs debug information
    #
    # Returns:
    #   None

    log_debug_ex "Entering handle_ctrl_z function"

    if [[ -n $BUFFER ]]; then
        log_debug "Ctrl+Z pressed with buffer content: '$BUFFER'"
        log_debug_ex "Sending buffer content to orchestrator for processing."

        # Sanitize the input before sending
        # local sanitized_input=$(sanitize_input "$BUFFER")
        # log_debug_ex "Sanitized input: '$sanitized_input'"

        # Send the input to the orchestrator
        log_debug_ex "Calling send_to_orchestrator with LLM prefix"
        local result=$(send_to_orchestrator "LLM:$BUFFER")
        log_debug_ex "Received result from orchestrator: '$result'"

        if [[ -n $result ]]; then
            log_debug_ex "Updating BUFFER with orchestrator result"
            BUFFER="$result"
            log_debug_ex "Triggering Zsh line editor redisplay"
            zle redisplay
            log_debug_ex "Command buffer updated with orchestrator result."
        else
            log_warning "No result received from orchestrator."
            log_debug_ex "BUFFER remains unchanged due to empty result"
        fi
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