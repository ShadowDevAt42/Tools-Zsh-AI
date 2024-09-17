#!/usr/bin/env zsh

zsh_copilot_debug "Loading zsh-copilot-utils.zsh"

# Function to get system information
get_system_info() {
    zsh_copilot_debug "Getting system info"
    local system_info

    case "$OSTYPE" in
        darwin*)
            system_info=$(sw_vers | awk '{print $2}' | paste -sd "." -)
            zsh_copilot_debug "Detected macOS system: $system_info"
            ;;
        linux*)
            if [ -f /etc/os-release ]; then
                system_info=$(. /etc/os-release && echo "$PRETTY_NAME")
            elif [ -f /etc/lsb-release ]; then
                system_info=$(. /etc/lsb-release && echo "$DISTRIB_DESCRIPTION")
            else
                system_info="Unknown Linux distribution"
            fi
            zsh_copilot_debug "Detected Linux system: $system_info"
            ;;
        *)
            system_info="Unknown operating system"
            zsh_copilot_debug "Detected unknown system: $system_info"
            ;;
    esac

    echo "$system_info"
}

# Function for detailed debugging
debug_log() {
    if [[ "${ZSH_COPILOT_CONFIG[DEBUG]}" == 'true' ]]; then
        local -A log_data=(
            [INPUT]="$1"
            [RESPONSE]="$2"
            [FIRST_CHAR]="$3"
            [SUGGESTION]="$4"
            [DATA]="$5"
        )
        
        zsh_copilot_debug "DEBUG LOG:"
        for key data in ${(kv)log_data}; do
            zsh_copilot_debug "$key: $(truncate_string "$data")"
        done
    fi
}

# Function to truncate and sanitize strings for logging
truncate_string() {
    local str="$1"
    local max_length="${2:-50}"
    str="${str//[$'\n\r']/ }"  # Replace newlines with spaces
    str="${str//[[:space:]]#+/ }"  # Collapse multiple spaces into one
    if (( ${#str} > max_length )); then
        echo "${str:0:$max_length}..."
    else
        echo "$str"
    fi
}

# Get and export system information
export SYSTEM=$(get_system_info)
zsh_copilot_debug "System info: $SYSTEM"

zsh_copilot_debug "zsh-copilot-utils.zsh loaded successfully"