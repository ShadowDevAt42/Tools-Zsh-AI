#!/bin/zsh



# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initializes the logging system
initialize_logs() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR"
    fi
	log_info "Log Dir found"
    if [[ -f "$LOG_FILE" ]]; then
        : > "$LOG_FILE"
    else
        touch "$LOG_FILE"
    fi
	log_info "Log started successfully"
}

# Logs a message with a given log level, timestamp, and color
log_message() {
    local log_level=$1
    local message=$2
    local color=$3
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local flag="{ZSH}"

    # Write the colored log entry to the log file
    echo -e "${color}[$timestamp] [$log_level] $flag $message${NC}" >> "$LOG_FILE"
}

log_info() {
    log_message "INFO" "$1" "$GREEN"
}

log_warning() {
    log_message "WARNING" "$1" "$YELLOW"
}

log_error() {
    log_message "ERROR" "$1" "$RED"
}

log_debug() {
    log_message "DEBUG" "$1" "$BLUE"
}

# Function to replace the previous zsh_copilot_debug
zsh_copilot_debug() {
    log_debug "$1"
}