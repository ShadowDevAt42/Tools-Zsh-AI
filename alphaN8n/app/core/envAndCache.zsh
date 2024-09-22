
init_env() {
    local env_file="${ROOT_DIR}/.env"
    log_devmod "Loading environment variables from: $env_file"

    if [[ ! -f "$env_file" ]]; then
        handle_error $E_FILE_NOT_FOUND "No .env file found. Run 'zsh install.zsh' to set up your environment."
        return $E_FILE_NOT_FOUND
    fi

    if [[ ! -s "$env_file" ]]; then
        handle_error $E_INVALID_INPUT "Empty .env file. Run 'zsh install.zsh' to set up your environment."
        return $E_INVALID_INPUT
    fi

    if [[ ! -r "$env_file" ]]; then
        handle_error $E_PERMISSION_DENIED "Cannot read .env file. Check permissions."
        return $E_PERMISSION_DENIED
    fi

    local env_vars_loaded=0
    while IFS='=' read -r key value; do
        if [[ ! -z "$key" && ! "$key" =~ ^# ]]; then
            if [[ -z "$value" ]]; then
                log_warning "Empty value for key '$key' in .env file."
                continue
            fi
            if ! validate_input "$key" "^[a-zA-Z_][a-zA-Z0-9_]*$"; then
                log_warning "Invalid key format '$key' in .env file."
                continue
            fi
            export "$key=$value"
            log_debug "Exported environment variable: $key"
            ((env_vars_loaded++))
        fi
    done < "$env_file"

    if [[ $env_vars_loaded -eq 0 ]]; then
        handle_error $E_INVALID_INPUT "No valid environment variables in .env file. Run 'zsh install.zsh' to set up your environment."
        return $E_INVALID_INPUT
    fi

    log_success "Environment variables loaded successfully: $env_vars_loaded variables set."
    return 0
}

init_user_cache() {
    log_info "Creating user cache file..."
    local cache_content=$(generate_cache_content)
    if ! echo "$cache_content" > "$CACHE_FILE"; then
        log_error "Failed to write to cache file: $CACHE_FILE"
        return 1
    fi
    log_success "User cache file created successfully: $CACHE_FILE"
    log_devmod "User cache file content:\n$cache_content"
    return 0
}