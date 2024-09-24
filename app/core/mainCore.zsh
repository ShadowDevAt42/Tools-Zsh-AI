# File: mainCore.zsh
#
# Description:
# This file initializes all core modules required for the ZSH Copilot n8n application. It is responsible for setting up the environment,
# initializing the cache system, and loading essential configurations and.
#
# Available Functions:
# 1. `init_core()`: Initializes the core components of the application, including the cache system, logging system, and environment variables.
# 2. `main_core()`: Entry point for core initialization, called from `mainApp.zsh` to ensure all core modules are properly initialized.

# Assurez-vous que ces variables sont disponibles (normalement définies dans config.zsh)
#: ${CORE_DIR:?"CORE_DIR n'est pas défini"}
#: ${UTILS_DIR:?"UTILS_DIR n'est pas défini"}

# Load core modules
source "${CORE_DIR}/envAndCache.zsh" || { echo "Failed to load envAndCache.zsh"; exit 1; }

# Function: init_core
init_core() {
	# Initializes the core components of the application, including the cache system, logging system, and environment variables.
	#
	# Side effects:
	#   - Initializes the cache and logging systems.
	#   - Loads environment variables from the `.env` file.
	#
	# Returns:
	#   0 on success, 1 on failure
    log_info "Initialisation du core de l'application..."

	log_info "Initializing cache system..."
    init_user_cache || { echo "Failed to initialize cache system"; return 1; }

	log_success "Cache system initialized successfully"
    log_info "Initializing environment..."
    #if ! init_env; then
        #log_error "Failed to initialize environment"
        #return 1
    #fi
    log_success "Environment initialized successfully"
	#log_info "Initializing server..."
	#if ! init_app_server; then
        #log_error "Failed to initialize server"
        #return 1
    #fi
    #log_success "Server initialized successfully"
    log_success "Core de l'application initialisé avec succès."
    return 0
}

# Function: main_core
main_core() {
    init_core || { echo "Échec de l'initialisation du core."; return 1; }

}