# File: init.zsh

# Description:
# This script manages the initialization of system files and dependency checks for the ZSH Copilot n8n application.
# It defines required commands and provides functions to set up necessary directories and files, manage log rotation,
# and verify system dependencies. The main functions available in this script are:
#
# Available Functions:
# 1. `init_sysfile()`: Initializes necessary folders and files for the application, manages log rotation, and handles cache files.
# 2. `check_command(command)`: Checks if a specified command is available in the system PATH.
# 3. `check_dependencies()`: Verifies that all required commands are available in the system.

# Source the logging and error handling module
source "${UTILS_DIR}/logsAndError.zsh" || { echo "Failed to load logsAndError.zsh"; exit 1; }
source "${UTILS_DIR}/security.zsh" || { echo "Failed to load security.zsh"; exit 1; }

# List of required commands for the application
REQUIRED_COMMANDS=("curl" "jq" "git" "nc")

# Function: init_sysfile
init_sysfile() {
	# Initializes necessary folders and files for the application, manages log rotation, and handles cache files.
	#
	# Side effects:
	#   - Creates LOG_DIR and CACHE_DIR if they don't exist.
	#   - Creates or manages LOG_FILE, including log rotation.
	#   - Creates or manages CACHE_FILE, with an option to reset on start.
	#   - Logs actions taken during initialization.
	#   - Handles errors using the handle_error function.
	#
	# Returns:
	#   0 on success, 1 on failure
    local dirs_to_create=("$LOG_DIR" "$CACHE_DIR")
    local log_files=("$LOG_FILE")
    local cache_files=("$CACHE_FILE")

    # Create directories
    for dir in "${dirs_to_create[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || { handle_error $E_FILESYSTEM "Failed to create directory: $dir"; return 1; }
            log_info "Created directory: $dir"
        else
            log_debug "Directory already exists: $dir"
        fi
    done

    # Handle log files
    for file in "${log_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            touch "$file" || { handle_error $E_FILESYSTEM "Failed to create file: $file"; return 1; }
            log_info "Created log file: $file"
        else
            log_debug "Log file already exists: $file"
            
            # Rotate log files
            if [[ -s "$file" ]]; then  # Check if file is not empty
                local timestamp=$(date +"%Y%m%d_%H%M%S")
                local backup_file="${file%.log}_${timestamp}.log"
                mv "$file" "$backup_file" || { handle_error $E_FILESYSTEM "Failed to rotate log file: $file"; return 1; }
                touch "$file" || { handle_error $E_FILESYSTEM "Failed to create new log file after rotation"; return 1; }
                log_info "Rotated log file: $file to $backup_file"
                
                # Remove old log files if exceeding MAX_LOG_FILE
                local log_count=$(ls -1 "${file%.log}"_*.log 2>/dev/null | wc -l)
                if (( log_count > MAX_LOG_FILE )); then
                    ls -1t "${file%.log}"_*.log | tail -n +$((MAX_LOG_FILE+1)) | xargs rm -f
                    log_info "Removed old log files, keeping latest $MAX_LOG_FILE files"
                fi
            fi
        fi
    done

    # Handle cache files
    for file in "${cache_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            touch "$file" || { handle_error $E_FILESYSTEM "Failed to create file: $file"; return 1; }
            log_info "Created cache file: $file"
        else
            log_debug "Cache file already exists: $file"
            if [[ "$CACHE_RESET_ON_START" == "true" && -s "$file" ]]; then
                : > "$file"  # Truncate file
                log_info "Reset cache file: $file"
            fi
        fi
    done

    return 0
}

# Function: check_command
check_command() {
	# Checks if a specified command is available in the system PATH.
	#
	# Arguments:
	#   $1 - The command to check
	#
	# Side effects:
	#   Logs a warning message if the command is not found.
	#
	# Returns:
	#   0 if the command is found, 1 if it is not found
    if ! command -v $1 &> /dev/null; then
        log_warning "Command not found: $1"
        return 1
    fi
    return 0
}

# Function: check_dependencies
check_dependencies() {
	# Verifies that all required commands are available in the system.
	#
	# Side effects:
	#   - Logs an error message listing all missing dependencies.
	#   - Uses the handle_error function to report dependency-related errors.
	#
	# Returns:
	#   0 if all dependencies are satisfied, 1 if any dependency is missing
    local missing_deps=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! check_command $cmd; then
            missing_deps+=($cmd)
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local missing_list=$(IFS=", "; echo "${missing_deps[*]}")
        handle_error $E_DEPENDENCIES "Missing dependencies: $missing_list"
        return 1
    fi
    return 0
}
