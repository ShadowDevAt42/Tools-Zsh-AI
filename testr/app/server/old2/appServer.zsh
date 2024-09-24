# appServer.zsh

# Function to start the Python app server
start_app_server() {
    log_status "Starting Python app server..."
    python3 "${SERVER_DIR}/appServer.py" &
    ZSH_COPILOT_APP_SERVER_PID=$!
    log_status "Python app server started with PID: $ZSH_COPILOT_APP_SERVER_PID"
}

# Function to stop the Python app server
stop_app_server() {
    if [[ -n "$ZSH_COPILOT_APP_SERVER_PID" ]]; then
        log_status "Stopping Python app server with PID: $ZSH_COPILOT_APP_SERVER_PID"
        kill $ZSH_COPILOT_APP_SERVER_PID
        unset ZSH_COPILOT_APP_SERVER_PID
    else
        log_status "No running Python app server found"
    fi
}

# Function to communicate with the socket server
communicate_with_server() {
    local input="$1"
    local host="${ZSH_COPILOT_CONFIG[SOCKET_HOST]}"
    local port="${ZSH_COPILOT_CONFIG[SOCKET_PORT]}"

    log_status "Sending request to server: $input"

    # Use netcat (nc) to send data to the socket server and receive response
    local response=$(echo "$input" | nc -w 5 $host $port)

    if [[ $? -ne 0 ]]; then
        log_status "Error: Failed to communicate with server"
        echo "Error: Failed to communicate with server"
        return 1
    fi

    log_status "Received response from server: $response"
    echo "$response"
}

# Function to ping the app server
ping_app_server() {
    local response=$(communicate_with_server "PING")
    if [[ $response == *"OK"* ]]; then
        echo "App server is running"
    else
        echo "App server is not responding"
    fi
}

# Initialize the app server when the plugin is loaded
init_app_server() {
    start_app_server
    # Wait a bit for the server to start
    sleep 10
    ping_app_server
}

# Clean up when the shell exits
cleanup_app_server() {
    stop_app_server
}

# Register the cleanup function to be called when the shell exits
add-zsh-hook zshexit cleanup_app_server

# Initialize the app server
#init_app_server