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
    log_devmod "Loading environment variables from: $env_file"

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
            log_debug "Exported environment variable: $key"
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