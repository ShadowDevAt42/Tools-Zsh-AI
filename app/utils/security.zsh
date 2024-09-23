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
    log_devmod "Validating file path: $file_path"
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

# Function to validate input against a pattern
validate_input() {
    # Validates the input string against the provided regular expression pattern.
    #
    # Args:
    #   input (str): The input string to validate.
    #   pattern (str): The regex pattern to match the input against.
    #
    # Returns:
    #   0 if the input matches the pattern.
    #   1 if the input does not match, after handling the error.

    local input=$1
    local pattern=$2

    if [[ $input =~ $pattern ]]; then
        log_debug "Input '$input' successfully validated against pattern '$pattern'."
        return 0
    else
        handle_error $E_INVALID_INPUT "Input '$input' does not match pattern '$pattern'"
        log_error "Validation failed for input '$input' against pattern '$pattern'."
        return 1
    fi
}