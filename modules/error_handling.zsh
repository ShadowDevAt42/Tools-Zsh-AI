#!/bin/zsh



# Error codes
E_GENERAL=1
E_INVALID_INPUT=2
E_FILE_NOT_FOUND=3
E_PERMISSION_DENIED=4

# Function to handle errors
handle_error() {
    local error_code=$1
    local error_message=$2
    
    case $error_code in
        $E_GENERAL)
            log_error "General error: $error_message"
            ;;
        $E_INVALID_INPUT)
            log_error "Invalid input: $error_message"
            ;;
        $E_FILE_NOT_FOUND)
            log_error "File not found: $error_message"
            ;;
        $E_PERMISSION_DENIED)
            log_error "Permission denied: $error_message"
            ;;
        *)
            log_error "Unknown error ($error_code): $error_message"
            ;;
    esac
    
    # You can add more actions here, like sending notifications or exiting the script
}

# Function to validate input
validate_input() {
    local input=$1
    local pattern=$2
    
    if [[ $input =~ $pattern ]]; then
        return 0
    else
        handle_error $E_INVALID_INPUT "Input '$input' does not match pattern '$pattern'"
        return 1
    fi
}