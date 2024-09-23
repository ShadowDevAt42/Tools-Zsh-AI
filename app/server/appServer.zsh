# File: plugin_zsh_n8n/app/mainApp.zsh

# ... (garder le contenu existant)

# Ajouter ces nouvelles fonctions pour gérer le serveur Python

# Function: start_python_server
start_python_server() {
    log_info "Starting Python server..."
    PYTHON_PATH=${PYTHON_PATH:-python3}
    PYTHON_SERVER_SCRIPT="${SERVER_DIR}/appServer.py"
    PID_DIR="${CACHE_DIR}/tmp"
    PID_FILE="${PID_DIR}/python_server.pid"

	export ROOT_DIR LOG_DIR CONFIG_DIR APP_DIR CACHE_DIR UTILS_DIR CORE_DIR SERVER_DIR TEMP_DIR
    export LOG_FILE CACHE_FILE SOCKET_FILE LOG_LEVEL

    # Vérifier si le script Python existe
    if [[ ! -f "$PYTHON_SERVER_SCRIPT" ]]; then
        log_error "Python server script not found at $PYTHON_SERVER_SCRIPT"
        return 1
    fi

    # Créer le répertoire PID s'il n'existe pas
    if [[ ! -d "$PID_DIR" ]]; then
        mkdir -p "$PID_DIR"
        if [[ $? -ne 0 ]]; then
            log_error "Failed to create PID directory: $PID_DIR"
            return 1
        fi
    fi

    # Lancer le serveur Python avec plus de logging
    log_info "Launching Python server with command: $PYTHON_PATH $PYTHON_SERVER_SCRIPT"
    nohup $PYTHON_PATH "$PYTHON_SERVER_SCRIPT" > "${LOG_DIR}/python_server.log" 2>&1 &

    PYTHON_SERVER_PID=$!
    log_info "Python server process started with PID: $PYTHON_SERVER_PID"

    # Attendre un peu pour voir si le processus survit
    sleep 2

    if ps -p $PYTHON_SERVER_PID > /dev/null; then
        echo $PYTHON_SERVER_PID > "$PID_FILE"
        if [[ $? -ne 0 ]]; then
            log_error "Failed to write PID file: $PID_FILE"
            return 1
        fi
        log_success "Python server started successfully with PID: $PYTHON_SERVER_PID"
    else
        log_error "Python server process died immediately. Check ${LOG_DIR}/python_server.log for details."
        return 1
    fi
}

# Function: stop_python_server
stop_python_server() {
    if [[ -f "${TEMP_DIR}/python_server.pid" ]]; then
        PYTHON_SERVER_PID=$(cat "${TEMP_DIR}/python_server.pid")
        if kill -0 $PYTHON_SERVER_PID 2>/dev/null; then
            kill $PYTHON_SERVER_PID
            log_info "Python server (PID: $PYTHON_SERVER_PID) stopped."
        else
            log_warning "Python server is not running."
        fi
        rm "${TEMP_DIR}/python_server.pid"
    else
        log_warning "Python server PID file not found."
    fi
}

send_to_python_server() {
    local message="$1"
    local socket_path="${SOCKET_FILE}"

    if [[ ! -S "$socket_path" ]]; then
        echo "Error: Socket file does not exist: $socket_path" >&2
        return 1
    fi

    echo "$message" | nc -U "$socket_path"
    if [[ $? -eq 0 ]]; then
        echo "Message sent to Python server: '$message'." >&2
    else
        echo "Failed to send message to Python server: '$message'." >&2
        return 1
    fi
}