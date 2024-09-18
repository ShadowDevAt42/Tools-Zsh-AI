#!/bin/zsh

# Source the config file
source "${0:A:h}/config/config.zsh"

# Source only the essential modules
source "${MODULE_DIR}/log.zsh"
source "${MODULE_DIR}/error_handling.zsh"
source "${MODULE_DIR}/core.zsh"
source "${ROOT_DIR}/dependencies.zsh"
source "${MODULE_DIR}/llm/llm.zsh"

# Function to run all initialization steps
initialize_application() {
    # Initialize logging
    initialize_logs
	log_info "Starting App..."
	log_info "Logs initialized successfully"
    log_info "Check all dependencies"
    # Check dependencies
    if ! check_dependencies; then
        local missing_deps=$(get_missing_dependencies)
        handle_error $E_GENERAL "Failed to satisfy all dependencies. Missing: $missing_deps"
        echo "Error: Some dependencies are missing. Please install: $missing_deps"
        exit 1
    fi
    log_info "All dependencies satisfied"
    # Initialize core functionality (which will load other modules)
    if ! initialize_core; then
        handle_error $E_GENERAL "Failed to initialize core functionality"
        echo "Error: Failed to initialize the application. Please check the logs for more information."
        exit 1
    fi

    log_info "Core initialized successfully"
}

# Main execution
main() {
    if ! initialize_application; then
        log_error "Application initialization failed"
        echo "Error: Failed to initialize the application. Please check the logs for more information."
        exit 1
    fi

    log_info "Application started successfully"

    # Main application logic goes here
    # ...
}

# Run the main function
main

# The trap for updating cache will be handled in core.zsh