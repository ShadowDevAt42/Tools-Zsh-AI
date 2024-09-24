# File: app/utils/security.zsh
#
# Description:
# This file contains security-related utility functions for the ZSH Copilot n8n application.
# It includes functions for input sanitization, file path validation, suspicious pattern detection,
# and input validation against regular expressions.

# Function: sanitize_input
# Sanitizes user input by removing potentially harmful characters
sanitize_input() {
    local input="$1"
    echo "${input//[^a-zA-Z0-9_.-]/}"
}

# Function: validate_file_path
# Validates that a given file path exists and is readable
validate_file_path() {
    local file_path="$1"
    log_devmod "Validating file path: $file_path"
    
    if [[ ! -f "$file_path" ]]; then
        handle_error $E_FILE_NOT_FOUND "File does not exist: $file_path"
        return 1
    fi
    if [[ ! -r "$file_path" ]]; then
        handle_error $E_PERMISSION_DENIED "Cannot read file: $file_path"
        return 1
    fi
    
    log_debug "File path '$file_path' is valid and readable."
    return 0
}

# Function: check_suspicious_input
# Checks the input string for any suspicious patterns that could indicate potential security threats
check_suspicious_input() {
    local input="$1"
    local suspicious_patterns=("rm -rf" "sudo" "|" ">" "<" "&")

    for pattern in "${suspicious_patterns[@]}"; do
        if [[ $input == *"$pattern"* ]]; then
            handle_error $E_INVALID_INPUT "Suspicious pattern detected: '$pattern'"
            return 1
        fi
    done
    
    log_debug "No suspicious patterns detected in input."
    return 0
}

# Function: secure_input
# Processes user input by sanitizing it and checking for suspicious patterns
secure_input() {
    local input="$1"
    local sanitized_input=$(sanitize_input "$input")
    log_debug "Sanitized input: '$sanitized_input'"
    
    if check_suspicious_input "$sanitized_input"; then
        log_success "User input '$sanitized_input' has been secured successfully."
        echo "$sanitized_input"
        return 0
    else
        log_error "User input '$sanitized_input' failed security checks."
        return 1
    fi
}

# Function: validate_input
# Validates the input string against the provided regular expression pattern
validate_input() {
    local input="$1"
    local pattern="$2"

    if [[ $input =~ $pattern ]]; then
        log_debug "Input '$input' successfully validated against pattern '$pattern'."
        return 0
    else
        handle_error $E_INVALID_INPUT "Input '$input' does not match pattern '$pattern'"
        return 1
    fi
}

# Export the functions
#export sanitize_input validate_file_path check_suspicious_input secure_input validate_input