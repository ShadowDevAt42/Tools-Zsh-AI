# Description:
#   Logging module for the application.
#   Provides functions to record messages with different severity levels.
#   Initializes the logging system, manages log files, and filters logs based on the configured log level.
#   Supports detailed logging for advanced debugging.

# Color codes for logs using 256-color mode for extended color support
RED='\033[0;31m'             # Red for ERROR
ORANGE='\033[38;5;208m'      # Orange for WARNING
GREEN='\033[0;32m'           # Green for SUCCESS
YELLOW='\033[0;33m'          # Yellow for INFO
VIOLET='\033[0;35m'          # Violet for DEBUG
PINK='\033[38;5;205m'        # Pink for DEBUG_EX
NC='\033[0m'                  # No Color

# Function to map log level names to numeric values for comparison
get_log_level_value() {
    # Maps log level names to numeric values.
    #
    # Args:
    #   level (str): The log level name (e.g., ERROR, WARNING, INFO, SUCCESS, DEBUG, DEBUG_EX).
    #
    # Returns:
    #   int: The numeric value corresponding to the log level.
    case "$1" in
        ERROR)
            echo 1
            ;;
        WARNING)
            echo 2
            ;;
        INFO)
            echo 3
            ;;
        SUCCESS)
            echo 4
            ;;
        DEBUG)
            echo 5
            ;;
        DEBUG_EX)
            echo 6
            ;;
        *)
            echo 0  # Undefined or unknown log level
            ;;
    esac
}

# Determine the current log level based on LOG_LEVEL variable
current_log_level=$(get_log_level_value "$LOG_LEVEL")

# Function to initialize the logging system
initialize_logs() {
    # Initializes the logging system by ensuring the log directory and file exist.
    # Configures the log file to record application logs.
    #
    # Logs:
    #   INFO: Log directory creation/found.
    #   INFO: Log file creation/truncation.
    #   INFO: Logging system initialization status.

    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR"
        log_info "Log directory created at $LOG_DIR."
        log_debug_ex "Log directory path: $LOG_DIR"
    else
        log_info "Log directory found at $LOG_DIR."
        log_debug_ex "Log directory already exists at path: $LOG_DIR"
    fi

    if [[ -f "$LOG_FILE" ]]; then
        : > "$LOG_FILE" # Truncate existing log file
        log_info "Existing log file truncated at $LOG_FILE."
        log_debug_ex "Log file truncated: $LOG_FILE"
    else
        touch "$LOG_FILE"
        log_info "Log file created at $LOG_FILE."
        log_debug_ex "Log file created at path: $LOG_FILE"
    fi
    log_info "Logging system initialized successfully."
}

# Function to log a message with a specific level
log_message() {
    # Logs a message with the given severity level, timestamp, and color.
    #
    # Args:
    #   log_level (str): Severity level of the log (e.g., INFO, WARNING, ERROR, SUCCESS, DEBUG, DEBUG_EX).
    #   message (str): The message to log.
    #   color (str): Color code for the log message.

    local log_level=$1
    local message=$2
    local color=$3
    local message_level=$(get_log_level_value "$log_level")

    # Only log the message if its level is less than or equal to the current log level
    if (( message_level <= current_log_level )); then
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        local flag="{ZSH}"
        echo -e "${color}[$timestamp] [$log_level] $flag $message${NC}" >> "$LOG_FILE"
    fi
}

# Function to log informational messages
log_info() {
    # Logs an informational message.
    #
    # Args:
    #   message (str): Informational message to log.

    log_message "INFO" "$1" "$YELLOW"
}

# Function to log warning messages
log_warning() {
    # Logs a warning message.
    #
    # Args:
    #   message (str): Warning message to log.

    log_message "WARNING" "$1" "$ORANGE"
}

# Function to log error messages
log_error() {
    # Logs an error message.
    #
    # Args:
    #   message (str): Error message to log.

    log_message "ERROR" "$1" "$RED"
}

# Function to log success messages
log_success() {
    # Logs a success message indicating successful completion of an operation.
    #
    # Args:
    #   message (str): Success message to log.

    log_message "SUCCESS" "$1" "$GREEN"
}

# Function to log debug messages
log_debug() {
    # Logs a debug message.
    #
    # Args:
    #   message (str): Debug message to log.

    log_message "DEBUG" "$1" "$VIOLET"
}

# Function to log advanced debug messages
log_debug_ex() {
    # Logs an advanced debug message with detailed information.
    #
    # Args:
    #   message (str): Advanced debug message to log.

    log_message "DEBUG_EX" "$1" "$PINK"
}

# Note:
# Ensure that this module is sourced before using its functions.
