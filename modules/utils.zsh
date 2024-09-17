#!/bin/zsh

# Utility functions for getting system information

# Function to get system information
get_system_info() {
    log_debug "Getting system info"
    local system_info
    case "$OSTYPE" in
        darwin*)
            system_info=$(sw_vers | awk '{print $2}' | paste -sd "." -)
            log_debug "Detected macOS system: $system_info"
            ;;
        linux*)
            if [ -f /etc/os-release ]; then
                system_info=$(. /etc/os-release && echo "$PRETTY_NAME")
            elif [ -f /etc/lsb-release ]; then
                system_info=$(. /etc/lsb-release && echo "$DISTRIB_DESCRIPTION")
            else
                system_info="Unknown Linux distribution"
            fi
            log_debug "Detected Linux system: $system_info"
            ;;
        *)
            system_info="Unknown operating system"
            log_debug "Detected unknown system: $system_info"
            ;;
    esac
    echo "$system_info"
}