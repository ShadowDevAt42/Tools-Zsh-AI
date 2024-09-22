#!/bin/zsh

# File: init.zsh

# Description:
# This script manages the initialization of system files and dependency checks for the ZSH Copilot n8n application.

source "${UTILS_DIR}/logsAndError.zsh" || { echo "Failed to load logsAndError.zsh"; exit 1; }
source "${UTILS_DIR}/security.zsh" || { echo "Failed to load security.zsh"; exit 1; }

# List of required commands for the application
REQUIRED_COMMANDS=("curl" "jq" "git" "nc")

# Function: create_directory
# Creates a directory if it doesn't exist
create_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || return 1
    fi
    return 0
}

# Function: create_file
# Creates a file if it doesn't exist
create_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        touch "$file" || return 1
    fi
    return 0
}

# Function: rotate_log_file
# Rotates the log file and manages old log files
rotate_log_file() {
    local file="$1"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${file%.log}_${timestamp}.log"
    
    mv "$file" "$backup_file" || return 1
    touch "$file" || return 1
    log_info "Rotated log file: $file to $backup_file"
    
    # Remove old log files if exceeding MAX_LOG_FILE
    local log_count=$(ls -1 "${file%.log}"_*.log 2>/dev/null | wc -l)
    if (( log_count > MAX_LOG_FILE )); then
        ls -1t "${file%.log}"_*.log | tail -n +$((MAX_LOG_FILE+1)) | xargs rm -f
        log_info "Removed old log files, keeping latest $MAX_LOG_FILE files"
    fi
    
    return 0
}

# Function: manage_cache_file
# Manages the cache file, optionally resetting it
manage_cache_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        create_file "$file" || return 1
        log_info "Created cache file: $file"
    elif [[ "$CACHE_RESET_ON_START" == "true" && -s "$file" ]]; then
        : > "$file"  # Truncate file
        log_info "Reset cache file: $file"
    fi
    return 0
}

# Function: init_sysfile
# Initializes necessary folders and files for the application
init_sysfile() {
    local dirs_to_create=("$LOG_DIR" "$CACHE_DIR")
    local log_files=("$LOG_FILE")
    local cache_files=("$CACHE_FILE")

    # Create directories
    for dir in "${dirs_to_create[@]}"; do
        create_directory "$dir" || { handle_error $E_FILESYSTEM "Failed to create directory: $dir"; return 1; }
    done

    log_status "Launching App"

    # Handle log files
    for file in "${log_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            create_file "$file" || { handle_error $E_FILESYSTEM "Failed to create file: $file"; return 1; }
        elif [[ -s "$file" ]]; then
            rotate_log_file "$file" || { handle_error $E_FILESYSTEM "Failed to rotate log file: $file"; return 1; }
        fi
    done

    # Handle cache files
    for file in "${cache_files[@]}"; do
        manage_cache_file "$file" || { handle_error $E_FILESYSTEM "Failed to manage cache file: $file"; return 1; }
    done

    return 0
}

# Function: check_command
# Checks if a specified command is available in the system PATH
check_command() {
    local cmd="$1"
    if ! command -v $cmd &> /dev/null; then
        log_warning "Command not found: $cmd"
        return 1
    fi
    return 0
}

# Function: check_dependencies
# Verifies that all required commands are available in the system
check_dependencies() {
    log_info "Checking all Dependencies"
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
    log_success "All dependencies are satisfied"
    return 0
}
