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

# Function to load environment variables
load_env() {
    if [[ ! -f "${ROOT_DIR}/.env" ]]; then
        echo "Error: .env file not found."
        echo "Please run 'zsh install.zsh' to set up your environment."
        handle_error $E_FILE_NOT_FOUND "No .env file found. User instructed to run install.zsh."
        return $E_FILE_NOT_FOUND
    fi

    if [[ ! -s "${ROOT_DIR}/.env" ]]; then
        echo "Error: .env file is empty."
        echo "Please run 'zsh install.zsh' to properly set up your environment."
        handle_error $E_INVALID_INPUT "Empty .env file. User instructed to run install.zsh."
        return $E_INVALID_INPUT
    fi

    if [[ ! -r "${ROOT_DIR}/.env" ]]; then
        echo "Error: Cannot read .env file. Please check file permissions."
        handle_error $E_PERMISSION_DENIED "Cannot read .env file. Check permissions."
        return $E_PERMISSION_DENIED
    fi

    local line_number=0
    local env_vars_loaded=0
    while IFS='=' read -r key value; do
        ((line_number++))
        if [[ ! -z "$key" && ! "$key" =~ ^# ]]; then
            if [[ -z "$value" ]]; then
                handle_error $E_INVALID_INPUT "Empty value for key '$key' on line $line_number in .env file"
                continue
            fi
            if ! validate_input "$key" "^[a-zA-Z_][a-zA-Z0-9_]*$"; then
                handle_error $E_INVALID_INPUT "Invalid key format '$key' on line $line_number in .env file"
                continue
            fi
            export "$key=$value"
            ((env_vars_loaded++))
        fi
    done < "${ROOT_DIR}/.env"

    if [[ $env_vars_loaded -eq 0 ]]; then
        echo "Error: No valid environment variables found in .env file."
        echo "Please run 'zsh install.zsh' to properly set up your environment."
        handle_error $E_INVALID_INPUT "No valid environment variables in .env file. User instructed to run install.zsh."
        return $E_INVALID_INPUT
    fi

    log_info "Environment variables loaded successfully: $env_vars_loaded variables set."
    return 0
}