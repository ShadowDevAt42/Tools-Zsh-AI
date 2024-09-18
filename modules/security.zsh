#!/bin/zsh

# Description:
#   Security module for the application.
#   Provides functions to sanitize and validate user input,
#   ensure file path security, and load environment variables securely.
#   Protects the application from malicious inputs and unauthorized access.

# Function to sanitize input
sanitize_input() {
    # Sanitizes user input by removing potentially harmful characters.
    #
    # Args:
    #   input (str): The raw user input to sanitize.
    #
    # Returns:
    #   The sanitized input string with only alphanumeric characters,
    #   underscores, dots, and hyphens retained.

    local input=$1
    # Remove any potentially harmful characters
    echo ${input//[^a-zA-Z0-9_.-]/}
}

# Function to validate file path
validate_file_path() {
    # Validates that a given file path exists and is readable.
    #
    # Args:
    #   file_path (str): The path of the file to validate.
    #
    # Returns:
    #   0 if the file exists and is readable.
    #   1 otherwise, after handling the appropriate error.

    local file_path=$1
    log_debug_ex "Validating file path: $file_path"
    if [[ ! -f "$file_path" ]]; then
        handle_error $E_FILE_NOT_FOUND "File does not exist: $file_path"
        log_error "Validation failed: File does not exist at '$file_path'."
        return 1
    fi
    if [[ ! -r "$file_path" ]]; then
        handle_error $E_PERMISSION_DENIED "Cannot read file: $file_path"
        log_error "Validation failed: Cannot read file at '$file_path'."
        return 1
    fi
    log_debug "File path '$file_path' is valid and readable."
    return 0
}

# Function to check for suspicious patterns in input
check_suspicious_input() {
    # Checks the input string for any suspicious patterns that could indicate
    # potential security threats or malicious intent.
    #
    # Args:
    #   input (str): The input string to check for suspicious patterns.
    #
    # Returns:
    #   0 if no suspicious patterns are detected.
    #   1 if any suspicious pattern is found, after handling the error.

    local input=$1
    local suspicious_patterns=(
        "rm -rf"
        "sudo"
        "|"
        ">"
        "<"
        "&"
    )

    for pattern in "${suspicious_patterns[@]}"; do
        if [[ $input == *"$pattern"* ]]; then
            handle_error $E_INVALID_INPUT "Suspicious pattern detected: '$pattern'"
            log_warning "Suspicious pattern '$pattern' detected in input."
            return 1
        fi
    done
    log_debug "No suspicious patterns detected in input."
    return 0
}

# Function to securely handle user input
secure_input() {
    # Processes user input by sanitizing it and checking for suspicious patterns.
    #
    # Args:
    #   input (str): The raw user input to secure.
    #
    # Returns:
    #   The sanitized input if it passes security checks.
    #   1 otherwise.

    local input=$1
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

# Function to load environment variables from .env file
load_env() {
    # Loads environment variables from the .env file located in the ROOT_DIR.
    # Validates the .env file's existence, content, and readability.
    # Exports valid environment variables for use in the application.
    #
    # Returns:
    #   0 if environment variables are loaded successfully.
    #   The corresponding error code otherwise.

    local env_file="${ROOT_DIR}/.env"
    log_debug_ex "Loading environment variables from: $env_file"

    if [[ ! -f "$env_file" ]]; then
        echo "Error: .env file not found."
        echo "Please run 'zsh install.zsh' to set up your environment."
        handle_error $E_FILE_NOT_FOUND "No .env file found. User instructed to run install.zsh."
        log_error "Failed to load environment variables: .env file not found."
        return $E_FILE_NOT_FOUND
    fi

    if [[ ! -s "$env_file" ]]; then
        echo "Error: .env file is empty."
        echo "Please run 'zsh install.zsh' to properly set up your environment."
        handle_error $E_INVALID_INPUT "Empty .env file. User instructed to run install.zsh."
        log_error "Failed to load environment variables: .env file is empty."
        return $E_INVALID_INPUT
    fi

    if [[ ! -r "$env_file" ]]; then
        echo "Error: Cannot read .env file. Please check file permissions."
        handle_error $E_PERMISSION_DENIED "Cannot read .env file. Check permissions."
        log_error "Failed to load environment variables: Cannot read .env file."
        return $E_PERMISSION_DENIED
    fi

    local line_number=0
    local env_vars_loaded=0
    while IFS='=' read -r key value; do
        ((line_number++))
        if [[ ! -z "$key" && ! "$key" =~ ^# ]]; then
            if [[ -z "$value" ]]; then
                handle_error $E_INVALID_INPUT "Empty value for key '$key' on line $line_number in .env file"
                log_warning "Empty value for key '$key' on line $line_number in .env file."
                continue
            fi
            if ! validate_input "$key" "^[a-zA-Z_][a-zA-Z0-9_]*$"; then
                handle_error $E_INVALID_INPUT "Invalid key format '$key' on line $line_number in .env file"
                log_warning "Invalid key format '$key' on line $line_number in .env file."
                continue
            fi
            export "$key=$value"
            log_debug "Exported environment variable: $key=$value"
            ((env_vars_loaded++))
        fi
    done < "$env_file"

    if [[ $env_vars_loaded -eq 0 ]]; then
        echo "Error: No valid environment variables found in .env file."
        echo "Please run 'zsh install.zsh' to properly set up your environment."
        handle_error $E_INVALID_INPUT "No valid environment variables in .env file. User instructed to run install.zsh."
        log_error "No valid environment variables loaded from .env file."
        return $E_INVALID_INPUT
    fi

    log_success "Environment variables loaded successfully: $env_vars_loaded variables set."
    return 0
}
