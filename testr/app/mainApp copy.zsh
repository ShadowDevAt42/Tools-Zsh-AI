#!/bin/zsh

# Source necessary utility functions and core components
source "${CORE_DIR}/mainCore.zsh"
source "${UTILS_DIR}/utils.zsh"

# Define the path for the Python server PID file
PYTHON_SERVER_PID_FILE="${HOME}/.zsh_python_server.pid"

# Function to start the Python server
start_python_server() {
    if [[ -f "$PYTHON_SERVER_PID_FILE" ]]; then
        local pid=$(cat "$PYTHON_SERVER_PID_FILE")
        if kill -0 $pid 2>/dev/null; then
            log_info "Python server is already running."
            return 0
        fi
    fi

    nohup python3 "${APP_DIR}/server/appServer.py" >/dev/null 2>&1 &
    echo $! > "$PYTHON_SERVER_PID_FILE"
    log_success "Python server started."
}

# Function to stop the Python server
stop_python_server() {
    if [[ -f "$PYTHON_SERVER_PID_FILE" ]]; then
        local pid=$(cat "$PYTHON_SERVER_PID_FILE")
        if kill -0 $pid 2>/dev/null; then
            kill $pid
            rm "$PYTHON_SERVER_PID_FILE"
            log_info "Python server stopped."
        else
            log_warning "Python server is not running."
        fi
    else
        log_warning "Python server is not running."
    fi
}

# Function to check and start the Python server if it's not running
check_python_server() {
    if [[ -f "$PYTHON_SERVER_PID_FILE" ]]; then
        local pid=$(cat "$PYTHON_SERVER_PID_FILE")
        if kill -0 $pid 2>/dev/null; then
            log_info "Python server is running."
        else
            log_warning "Python server is not running. Starting it now..."
            start_python_server
        fi
    else
        log_warning "Python server is not running. Starting it now..."
        start_python_server
    fi
}

init_app() {
    log_info "Initializing application..."
    
    # Initialize core components
    if ! init_core; then
        log_error "Failed to initialize core components"
        return 1
    fi
    
    # Start Python server
    check_python_server
    
    # Initialize other necessary components here
    # ...

    log_success "Application initialized successfully"
    return 0
}

run_app() {
    log_info "Starting main application loop..."
    
    # Main application loop
    while true; do
        read -r "cmd?Enter a command (or 'exit' to quit): "
        case "$cmd" in
            exit)
                log_info "Exiting application..."
                break
                ;;
            start_server)
                start_python_server
                ;;
            stop_server)
                stop_python_server
                ;;
            restart_server)
                stop_python_server
                start_python_server
                ;;
            *)
                # Process other commands
                process_command "$cmd"
                ;;
        esac
    done
    
    # Perform any cleanup operations here
    cleanup
    log_info "Application terminated"
}

process_command() {
    local cmd="$1"
    # Implement command processing logic here
    log_info "Processing command: $cmd"
    # Add your command handling logic
}

cleanup() {
    log_info "Performing cleanup operations..."
    # Stop Python server
    stop_python_server
    # Add any other necessary cleanup operations here
}

# This function will be called from the main script
main_app() {
    if init_app; then
        run_app
    else
        log_error "Application initialization failed. Exiting."
        return 1
    fi
}

# Trap to ensure the Python server is stopped when the script exits
trap stop_python_server EXIT