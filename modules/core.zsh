#!/bin/zsh

# Source all other necessary modules
source "${MODULE_DIR}/user.zsh"
source "${MODULE_DIR}/utils.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/security.zsh"
source "${CONFIG_DIR}/config.zsh"

# Initializes the core functionality of the application.
initialize_core() {
    log_info "Initializing application core..."

    # Initialize user data
    initialize_user

    # Any additional core initialization steps can be added here
    # For example:
    # - Setting up environment variables
    # - Initializing database connections
    # - Loading additional configuration files

    log_info "Application core initialized."

    # Set up the trap for updating cache when the terminal session ends
    trap update_cache_on_cd EXIT
}