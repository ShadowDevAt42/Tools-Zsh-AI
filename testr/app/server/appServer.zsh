# File: app/server/appServer.zsh

# Description:
# This file contains functions for managing the Python server component of the ZSH Copilot n8n application.
# It includes functions to start and stop the Python server, as well as send messages to it.

# Function: start_python_server
# Starts the Python server and manages its PID
start_python_server() {
    log_info "Starting Python server..."
    local python_path=${PYTHON_PATH:-python3}
    local python_server_script="${SERVER_DIR}/appServer.py"
    local pid_dir="${CACHE_DIR}/tmp"
    local pid_file="${pid_dir}/python_server.pid"

    # Export necessary environment variables
    export ROOT_DIR LOG_DIR CONFIG_DIR APP_DIR CACHE_DIR UTILS_DIR CORE_DIR SERVER_DIR TEMP_DIR
    export LOG_FILE CACHE_FILE SOCKET_FILE LOG_LEVEL

    # Check if the Python script exists
    if [[ ! -f "$python_server_script" ]]; then
        log_error "Python server script not found at $python_server_script"
        return 1
    fi

    # Create PID directory if it doesn't exist
    if [[ ! -d "$pid_dir" ]]; then
        if ! mkdir -p "$pid_dir"; then
            log_error "Failed to create PID directory: $pid_dir"
            return 1
        fi
    fi

    # Launch the Python server
    log_info "Launching Python server with command: $python_path $python_server_script"
    nohup $python_path "$python_server_script" > "${LOG_DIR}/python_server.log" 2>&1 &

    local python_server_pid=$!
    log_info "Python server process started with PID: $python_server_pid"

    # Wait a bit to see if the process survives
    sleep 2

    if ps -p $python_server_pid > /dev/null; then
        if ! echo $python_server_pid > "$pid_file"; then
            log_error "Failed to write PID file: $pid_file"
            return 1
        fi
        log_success "Python server started successfully with PID: $python_server_pid"
    else
        log_error "Python server process died immediately. Check ${LOG_DIR}/python_server.log for details."
        return 1
    fi
}

# Function: stop_python_server
# Stops the Python server if it's running
stop_python_server() {
    local pid_file="${TEMP_DIR}/python_server.pid"
    if [[ -f "$pid_file" ]]; then
        local python_server_pid=$(cat "$pid_file")
        if kill -0 $python_server_pid 2>/dev/null; then
            kill $python_server_pid
            log_info "Python server (PID: $python_server_pid) stopped."
        else
            log_warning "Python server is not running."
        fi
        rm "$pid_file"
    else
        log_warning "Python server PID file not found."
    fi
}

# Function: send_to_python_server
# Sends a message to the Python server via Unix socket
send_to_python_server() {
    local message="$1"
    local socket_path="${SOCKET_FILE}"

    if [[ ! -S "$socket_path" ]]; then
        log_error "Socket file does not exist: $socket_path"
        return 1
    fi

    if echo "$message" | nc -U "$socket_path"; then
        log_info "Message sent to Python server: '$message'."
    else
        log_error "Failed to send message to Python server: '$message'."
        return 1
    fi
}

# Export the functions
#export start_python_server stop_python_server send_to_python_server