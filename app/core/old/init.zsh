#!/bin/zsh

# File: /plugin_zsh_n8n/init.zsh

# Description:
# This script initializes the environment and cache for the ZSH Copilot n8n application.
# It serves as the primary initialization point, called before the main application starts.

source "${CORE_DIR}/envAndCache.zsh"

# Function: init_environment
# Initializes the application environment by loading environment variables.
#
# Returns:
#   0 on success, non-zero on failure
init_environment() {
    log_info "Initializing environment..."
    if ! load_env; then
        log_error "Failed to initialize environment"
        return 1
    fi
    log_success "Environment initialized successfully"
    return 0
}

# Function: init_cache
# Initializes the user cache system.
#
# Returns:
#   0 on success, non-zero on failure
init_cache() {
    log_info "Initializing cache system..."
    if ! create_user_cache; then
        log_error "Failed to initialize cache system"
        return 1
    fi
    log_success "Cache system initialized successfully"
    return 0
}

# Function: main_init
# Main initialization function that orchestrates the entire initialization process.
#
# Returns:
#   0 on success, non-zero on failure
main_init() {
    if ! init_environment; then
        return 1
    fi
    if ! init_cache; then
        return 1
    fi
    return 0
}

# Execute main initialization
main_init