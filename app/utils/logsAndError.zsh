# File: app/utils/logsAndError.zsh

# Description :
# This module combines logging and error handling functionalities for the ZSH Copilot n8n application.
# It provides functions to record messages with different severity levels, initialize the logging system,
# manage log files, and filter logs based on the configured log level.
# Additionally, it defines error codes and provides functions to handle and log errors consistently across the application.

# Available Functions:
# 1. get_log_level_value(level)
# 2. log_message(log_level, message, color)
# 3. log_info(message)
# 4. log_warning(message)
# 5. log_error(message)
# 6. log_success(message)
# 7. log_status(message)
# 8. log_debug(message)
# 9. log_devmod(message)
# 10. handle_error(error_code, error_message)


# Color codes for logs using 256-color mode for extended color support
RED='\033[1;31m'             # Red for ERROR
ORANGE='\033[38;5;208m'      # Orange for WARNING
GREEN='\033[1;32m'           # Green for SUCCESS
YELLOW='\033[0;33m'          # Yellow for INFO
BLUE='\033[0;34m'            # Blue for STATUS
PURPLE='\033[0;35m'           # Violet for DEBUG
PINK='\033[38;5;205m'        # Pink for DEVMOD (development mode)
NC='\033[0m'                 # No Color
# Color codes for hard_logs
H_RED=$'\e[31m'
H_ORANGE=$'\e[38;5;208m'
H_GREEN=$'\e[32m'
H_YELLOW=$'\e[33m'
H_BLUE=$'\e[34m'
H_PURPLE=$'\e[35m'
H_PINK=$'\e[38;5;205m'
H_NC=$'\e[0m'  # Pas de couleur
# Function to map log level names to numeric values for comparison
get_log_level_value() {
    local level="$1"
    case "$level" in
        ERROR)   echo 4 ;;
        WARNING) echo 4 ;;
        SUCCESS) echo 4 ;;
        INFO)    echo 4 ;;
        STATUS)  echo 4 ;;
        DEBUG)   echo 6 ;;
        DEVMOD)  echo 7 ;;
        *)       echo 0 ;;  # Undefined or unknown log level
    esac
}

# Determine the current log level based on LOG_LEVEL variable
current_log_level=$(get_log_level_value "$LOG_LEVEL")

# Function to log a message with a specific level
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

# Function to log a message with a specific level
hard_log_message() {
    local hard_log_level="$1"
    local message="$2"
    local color="$3"
    local message_level=$(get_log_level_value "$hard_log_level")

    # Only log the message if its level is less than or equal to the current log level
    if (( message_level <= current_log_level )) && [[ "$HARD_LOG_LEVEL" == "true" ]]; then
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        local flag="{ZSH}"
        echo -e "${color}[$hard_log_level] $message${NC}"
    fi
}

# Logging functions for different severity levels
hard_log_info()    { hard_log_message "INFO"    "$1" "$H_YELLOW"; }
hard_log_warning() { hard_log_message "WARNING" "$1" "$H_ORANGE"; }
hard_log_error()   { hard_log_message "ERROR"   "$1" "$H_RED";    }
hard_log_success() { hard_log_message "SUCCESS" "$1" "$H_GREEN";  }
hard_log_status()  { hard_log_message "STATUS"  "$1" "$H_BLUE";   }
hard_log_debug()   { hard_log_message "DEBUG"   "$1" "$H_PURPLE"; }
hard_log_devmod()  { hard_log_message "DEVMOD"  "$1" "$H_PINK";   }

# HANDLING ERROR
# ---------------------------
# Manages errors consistently throughout the application based on the provided error code and message.
# This function centralizes error handling, logs relevant error messages, and enables triggering specific actions
# (such as sending notifications or terminating the script) based on the type of error.
#
# Args:
#   error_code (int): Numeric code representing the type of error. Error codes are defined in the config.zsh
#                     to cover common error scenarios (e.g., $E_GENERAL, $E_INVALID_INPUT, etc.).
#   error_message (str): Detailed message describing the error, useful for debugging and traceability.
#
# Logic:
#   - Logs an appropriate error message based on the error code.
#   - Specific error codes trigger particular actions like logging with different severity levels.
#   - Unknown errors are also handled to ensure comprehensive exception management.
#
# Usage Example:
#   handle_error $E_FILE_NOT_FOUND "The configuration file is missing in the specified directory."
#
# Potential Improvements:
#   - Add specific actions like sending a notification or executing recovery scripts.
#   - Implement a retry or automatic recovery mechanism for certain errors.
#   - Integrate a function to delete temporary files or clean up the cache in case of critical errors.
#

# Function to handle errors
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
