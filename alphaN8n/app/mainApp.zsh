# File: plugin_zsh_n8n/app/mainApp.zsh

# Description:
# This is the main application file for the ZSH Copilot n8n project. It manages the initialization, execution, 
# and cleanup of the application. The script includes functions for initializing core components, running the main 
# application loop, processing user commands, and performing cleanup tasks before termination.
#
# Available Functions:
# 1. `init_app()`: Initializes the application by setting up core components and logs the initialization process.
# 2. `run_app()`: Runs the main application loop, processes user commands, and handles the application's lifecycle.
# 3. `process_command(command)`: Processes a single user command and logs the command being processed.
# 4. `cleanup()`: Performs necessary cleanup operations before the application terminates.
# 5. `main_app()`: Main entry point for the application, initializing and running the app.

# Source necessary utility functions and core components
source "${CORE_DIR}/mainCore.zsh" || { echo "Failed to load mainCore.zsh"; return 1; }
source "${UTILS_DIR}/utils.zsh" || { echo "Failed to load utils.zsh"; return 1; }
source "${SERVER_DIR}/appServer.zsh" || { echo "Failed to load appServer.zsh"; return 1; }
#source "${SERVER_DIR}/appServer.zsh" || { echo "Failed to load appServer.zsh"; return 1; }

# Function: handle_signal
handle_signal() {
	# Handles termination signals (SIGINT, SIGTERM) and performs cleanup operations.
	#
	# Side effects:
	#   - Logs information about receiving the signal
	#   - Calls the cleanup function before exiting
    log_info "Received termination signal. Cleaning up..."
    cleanup
    exit 0
}
# Trap termination signals and call handle_signal
trap handle_signal SIGINT SIGTERM

# Create a ZLE widget for the Ctrl+Z handler
zle -N handle_ctrl_z

# Bind Ctrl+Z to the handler
bindkey '^Z' handle_ctrl_z

# Function: init_app
init_app() {
	# Initializes the application by setting up core components.
	#
	# Side effects:
	#   - Logs information about the initialization process.
	#   - Calls init_core to initialize core components.
	#
	# Returns:
	#   0 on success, 1 on failure
    log_info "Initializing application..."
    
    # Initialize core components
    if ! init_core; then
        log_error "Failed to initialize core components"
        return 1
    fi
    log_success "Application initialized successfully"
	start_python_server
    return 0
}

# Function: run_app
run_app() {
	# Runs the main application loop, processing user commands until exit.
	#
	# Side effects:
	#   - Logs information about application start and termination.
	#   - Reads user input and processes commands.
	#   - Calls cleanup function before termination.
    log_info "Plugin initialized and ready. Press Ctrl+Z to display 'Hello World'."
    # The plugin will now just wait for Ctrl+Z input
    
    
    # Perform any cleanup operations here
    #cleanup
    
    log_info "Application terminated"
}

# Function: process_command
process_command() {
	# Processes a single user command.
	#
	# Arguments:
	#   $1 - The command to process
	#
	# Side effects:
	#   - Logs information about the command being processed
    local cmd="$1"
    # Implement command processing logic here
    log_info "Processing command: $cmd"
    # Add your command handling logic
}

# Function: cleanup
cleanup() {
	# Performs necessary cleanup operations before application termination.
	#
	# Side effects:
	#   - Logs information about the cleanup process
	log_info "Performing cleanup operations..."
    stop_python_server
    log_info "Performing cleanup operations..."
    # Add any necessary cleanup operations here
}

# Function: main_app
main_app() {
	# Main entry point for the application. Initializes and runs the app.
	#
	# Side effects:
	#   - Logs errors if initialization or execution fails.
	#
	# Returns:
	#   0 on success, 1 on failure
    if init_app; then
        run_app
    else
        log_error "Application initialization failed. Exiting."
        return 1
    fi
}