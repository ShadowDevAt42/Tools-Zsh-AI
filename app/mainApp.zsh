# File: plugin_zsh_n8n/app/mainApp.zsh

# Description:
# This is the main application file for the ZSH Copilot n8n project. It manages the initialization, execution, 
# and cleanup of the application. The script includes functions for initializing core components, running the main 
# application loop, processing user commands, and performing cleanup tasks before termination.
#
# Available Functions:
# 1. `init_app()`: Initializes the application by setting up core components and logs the initialization process.
# 3. `process_command(command)`: Processes a single user command and logs the command being processed.
# 4. `cleanup()`: Performs necessary cleanup operations before the application terminates.
# 5. `main_app()`: Main entry point for the application, initializing and running the app.

# Source necessary utility functions and core components
source "${CORE_DIR}/mainCore.zsh" || { echo "Failed to load mainCore.zsh"; return 1; }
source "${UTILS_DIR}/utils.zsh" || { echo "Failed to load utils.zsh"; return 1; }
source "${SERVER_DIR}/appServer.zsh" || { echo "Failed to load appServer.zsh"; return 1; }

# Function: handle_signal
handle_signal() {
    log_info "Signal de terminaison reçu. Nettoyage en cours..."
    cleanup
    return 0
}
# Trap termination signals and call handle_signal
trap handle_signal SIGINT SIGTERM

handle_ctrl_a() {
    stop_python_server
}
# Create a ZLE widget for the Ctrl+Z handler
zle -N handle_ctrl_z
bindkey '^Z' handle_ctrl_z

zle -N handle_ctrl_a
bindkey '^A' handle_ctrl_a

# Function: init_app
init_app() {
    log_info "Initialisation de l'application..."
    init_core || { log_error "Échec d'initialisation des composants principaux"; return 1; }
    log_success "Application initialisée avec succès"
    return 0
}

# Function: cleanup
cleanup() {
    log_info "Exécution des opérations de nettoyage..."
	stop_python_server
    # Ajoutez ici toute autre opération de nettoyage nécessaire
}

# Function: main_app
main_app() {
    # Exécuter l'initialisation en arrière-plan
    init_app &
    local init_pid=$!

    # Afficher un message pendant l'initialisation
    hard_log_info "Initialisation de l'application en cours... Vous pouvez utiliser la console pendant ce temps."

    # Attendre la fin de l'initialisation
    wait $init_pid

    if [ $? -ne 0 ]; then
        echo "Échec de l'initialisation de l'application."
        return 1
    fi
    # S'assurer que le serveur Python est en cours d'exécution
    ensure_python_server_running
	hard_log_success "Application initialisée avec succès. Le serveur Python est en cours d'exécution en arrière-plan."
    hard_log_info "Vous pouvez maintenant utiliser l'application normalement."
    log_info "Application initialisée avec succès. En attente des entrées Ctrl+Z..."
}

# Appeler reconnect_to_server au lancement de la console
ensure_python_server_running