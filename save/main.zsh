#!/bin/zsh

# Description:
#   The main entry point of the application.
#   Initializes configurations, the logging system, and essential modules.
#   Manages the overall lifecycle of the application.

# Source the main configuration file
source "${0:A:h}/config/config.zsh"

# Source essential modules
source "${MODULE_DIR}/log.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/core.zsh"
source "${ROOT_DIR}/dependencies.zsh"
source "${MODULE_DIR}/llm/llm.zsh"

# Function to initialize the application
initialize_application() {
    # Initializes all necessary steps to start the application.
    #
    # Steps:
    #   - Initializes the logging system.
    #   - Checks and installs required dependencies.
    #   - Initializes the core functionalities of the application.
    #
    # Returns:
    #   0 if initialization succeeds, 1 otherwise.

    # Initialize the logging system
    initialize_logs
    log_success "Logging system initialized successfully."
    log_debug_ex "Log directory: $LOG_DIR"
    log_debug_ex "Log file: $LOG_FILE"

    log_info "Starting application initialization process..."
    log_debug_ex "Beginning application initialization sequence."
	log_info "Starting dependencies check process..."
    # Check for required dependencies
    if ! check_dependencies; then
        local missing_deps=$(get_missing_dependencies)
        handle_error $E_GENERAL "Failed to satisfy all dependencies."
        log_error "Missing dependencies: $missing_deps"
        echo "Error: Some dependencies are missing. Please install: $missing_deps"
        exit 1
    fi
    log_success "All dependencies satisfied."

    # Initialize core functionalities of the application
    if ! initialize_core; then
        handle_error $E_GENERAL "Failed to initialize core functionality."
        log_error "Failed to initialize core functionality."
        echo "Error: Failed to initialize the application. Please check the logs for more information."
        exit 1
    fi

    log_success "Core functionalities initialized successfully."
    log_debug_ex "Application initialization sequence completed."
}

# Main execution function
main() {
    # The main function that launches the application after initialization.
    #
    # Executes initialization steps and starts the main application logic.

    log_info "Initializing application..."
    log_debug_ex "Calling initialize_application function."

    if ! initialize_application; then
        log_error "Application initialization failed."
        echo "Error: Failed to initialize the application. Please check the logs for more information."
        exit 1
    fi

    log_success "Application started successfully."
    log_debug_ex "Entering main application loop."

    # Main application logic goes here
    # For example, starting the orchestrator, handling user input, etc.
    # ...

    log_debug_ex "Main application loop terminated gracefully."
    log_success "Application has exited without issues."
}

# Execute the main function
main

# The trap for updating cache will be handled in core.zsh
