# Description:
#   Core module of the application.
#   Manages the initialization of main functionalities such as user data, environment setup, and the Python orchestrator.
#   Configures traps and essential background processes for the application's operation.

# Source all other necessary modules
source "${MODULE_DIR}/user.zsh"
source "${MODULE_DIR}/utils.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/security.zsh"
source "${CONFIG_DIR}/config.zsh"

# Function to initialize the core functionalities of the application
initialize_core() {
    # Initializes the core functionalities of the application.
    #
    # Steps:
    #   - Initializes user data.
    #   - Sets up environment variables.
    #   - Launches the Python orchestrator in the background.
    #   - Configures traps for session management.
    #
    # Returns:
    #   0 if initialization succeeds, 1 otherwise.

    log_info "Initializing application core..."
    log_debug_ex "Starting core initialization."

	log_info "Starting user initialization process..."

    # Initialize user data
    initialize_user
    log_success "User data initialized."

	log_info "Starting env install process..."
    # Load environment variables
    if load_env; then
        log_success "Environment setup completed successfully."
    else
        log_warning "Environment setup completed with warnings. Check the logs for details."
    fi

    # Launch the Python orchestrator in the background
    if python3 "${ORCHE_DIR}/main.py" &; then
        log_info "Python orchestrator launched successfully."
        log_debug_ex "Orchestrator script path: ${ORCHE_DIR}/main.py"
    else
        log_error "Failed to launch the Python orchestrator."
        return 1
    fi

    # Send a PING signal to the orchestrator to verify its status
    send_to_orchestrator "PING"
    log_info "PING signal sent to the orchestrator."

    # Additional core initialization steps can be added here
    # For example:
    #   - Setting up additional environment variables
    #   - Initializing database connections
    #   - Loading additional configuration files

    log_info "Application core initialized successfully."
    log_debug_ex "Core initialization completed."

    # Set up a trap to update the cache when the terminal session ends
    trap update_cache_on_cd EXIT
    log_info "Trap configured to update cache on session exit."
    log_debug_ex "Cache update trap set on EXIT signal."

    return 0
}
