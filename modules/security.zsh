#!/bin/zsh


# Function to sanitize input
sanitize_input() {
    local input=$1
    # Remove any potentially harmful characters
    echo ${input//[^a-zA-Z0-9_.-]/}
}

# Function to validate file path
validate_file_path() {
    local file_path=$1
    if [[ ! -f "$file_path" ]]; then
        handle_error $E_FILE_NOT_FOUND "File does not exist: $file_path"
        return 1
    fi
    if [[ ! -r "$file_path" ]]; then
        handle_error $E_PERMISSION_DENIED "Cannot read file: $file_path"
        return 1
    fi
    return 0
}

# Function to check for suspicious patterns in input
check_suspicious_input() {
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
            handle_error $E_INVALID_INPUT "Suspicious pattern detected: $pattern"
            return 1
        fi
    done
    return 0
}

# Function to securely handle user input
secure_input() {
    local input=$1
    local sanitized_input=$(sanitize_input "$input")
    if check_suspicious_input "$sanitized_input"; then
        echo "$sanitized_input"
        return 0
    else
        return 1
    fi
}