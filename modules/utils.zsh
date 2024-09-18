#!/bin/zsh

# Description:
#   Utility module for the application.
#   Provides functions to retrieve system information and communicate with the Python orchestrator.
#   Enhances the application's ability to adapt to different environments and maintain communication channels.

# Function to get system information
get_system_info() {
    # Retrieves detailed system information based on the operating system.
    #
    # Logs the type of system detected and returns the system information.
    #
    # Returns:
    #   A string containing the system's version or distribution name.

    log_debug "Retrieving system information..."
    local system_info
    case "$OSTYPE" in
        darwin*)
            system_info=$(sw_vers | awk '{print $2}' | paste -sd "." -)
            log_debug "Detected macOS system: Version $system_info."
            ;;
        linux*)
            if [ -f /etc/os-release ]; then
                system_info=$(. /etc/os-release && echo "$PRETTY_NAME")
            elif [ -f /etc/lsb-release ]; then
                system_info=$(. /etc/lsb-release && echo "$DISTRIB_DESCRIPTION")
            else
                system_info="Unknown Linux distribution"
            fi
            log_debug "Detected Linux system: $system_info."
            ;;
        *)
            system_info="Unknown operating system"
            log_warning "Unknown operating system detected: $system_info."
            ;;
    esac
    echo "$system_info"
}

# Function to send messages to the Python orchestrator
send_to_orchestrator() {
    # Sends a message to the Python orchestrator via a Unix socket.
    #
    # Args:
    #   message (str): The message to send to the orchestrator.

    local message="$1"
    if [[ -z "$SOCK_PATH" ]]; then
        log_error "Socket path is not defined. Cannot send message to orchestrator."
        return 1
    fi

    echo "$message" | nc -U "${SOCK_PATH}"
    if [[ $? -eq 0 ]]; then
        log_info "Message sent to orchestrator: '$message'."
        log_debug_ex "Sent message: '$message' via socket: '$SOCK_PATH'."
    else
        log_error "Failed to send message to orchestrator: '$message'."
    fi
}

# Note:
# Ensure that the Python orchestrator is running and listening on the specified SOCKET_PATH.
# The 'nc' (netcat) utility is used for sending messages via Unix sockets.
