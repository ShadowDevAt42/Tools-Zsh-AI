# File: app/utils/logsAndError.zsh

# Description:
# This module combines logging and error handling functionalities for the ZSH Copilot n8n application.
# It provides functions to record messages with different severity levels, initialize the logging system,
# manage log files, and filter logs based on the configured log level.
# Additionally, it defines error codes and provides functions to handle and log errors consistently across the application.

# Color codes for logs using 256-color mode for extended color support
RED='\033[1;31m'             # Red for ERROR
ORANGE='\033[38;5;208m'      # Orange for WARNING
GREEN='\033[1;32m'           # Green for SUCCESS
YELLOW='\033[0;33m'          # Yellow for INFO
BLUE='\033[0;34m'            # Blue for STATUS
PURPLE='\033[0;35'           # Violet for DEBUG
PINK='\033[38;5;205m'        # Pink for DEVMOD (development mode)
NC='\033[0m'                 # No Color

# Function: get_log_level_value
# Maps log level names to numeric values for comparison
get_log_level_value() {
    local level="$1"
    case "$level" in
        ERROR)   echo 1 ;;
        WARNING) echo 2 ;;
        SUCCESS) echo 3 ;;
        INFO)    echo 4 ;;
        STATUS)  echo 5 ;;
        DEBUG)   echo 6 ;;
        DEVMOD)  echo 7 ;;
        *)       echo 0 ;;  # Undefined or unknown log level
    esac
}

# Determine the current log level based on LOG_LEVEL variable
current_log_level=$(get_log_level_value "$LOG_LEVEL")

# Function: log_message
# Logs a message with a specific level, timestamp, and color
log_message() {
    local log_level="$1"
    local message="$2"
    local color="$3"
    local message_level=$(get_log_level_value "$log_level")

    # Only log the message if its level is less than or equal to the current log level
    if (( message_level <= current_log_level )); then
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        local flag="{ZSH}"
        echo -e "${color}[$timestamp] [$log_level] $flag $message${NC}" >> "$LOG_FILE"
    fi
}

# Logging functions for different severity levels
log_info()    { log_message "INFO"    "$1" "$YELLOW"; }
log_warning() { log_message "WARNING" "$1" "$ORANGE"; }
log_error()   { log_message "ERROR"   "$1" "$RED";    }
log_success() { log_message "SUCCESS" "$1" "$GREEN";  }
log_status()  { log_message "STATUS"  "$1" "$BLUE";   }
log_debug()   { log_message "DEBUG"   "$1" "$PURPLE"; }
log_devmod()  { log_message "DEVMOD"  "$1" "$PINK";   }

# Function: handle_error
# Manages errors consistently throughout the application
handle_error() {
    local error_code="$1"
    local error_message="$2"

    log_devmod "Handling error with code $error_code: $error_message"

    case $error_code in
        $E_GENERAL)
            log_error "General error occurred: $error_message"
            ;;
        $E_INVALID_INPUT)
            log_error "Invalid input provided: $error_message"
            ;;
        $E_FILE_NOT_FOUND)
            log_error "File not found: $error_message"
            ;;
        $E_PERMISSION_DENIED)
            log_error "Permission denied: $error_message"
            ;;
        $E_FILESYSTEM)
            log_error "Filesystem error: $error_message"
            ;;
        $E_DEPENDENCIES)
            log_error "Dependency error: $error_message"
            ;;
        *)
            log_error "Unknown error (Code: $error_code): $error_message"
            ;;
    esac
}

# Export the functions
#export get_log_level_value log_message log_info log_warning log_error log_success log_status log_debug log_devmod handle_error
