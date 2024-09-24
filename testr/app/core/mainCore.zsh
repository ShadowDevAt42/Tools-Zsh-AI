# File: mainCore.zsh
#
# Description:
# This file initializes all core modules required for the ZSH Copilot n8n application.
# It is responsible for setting up the environment, initializing the cache system,
# and loading essential configurations.
#
# Available Functions:
# 1. `init_core()`: Initializes the core components of the application.
# 2. `main_core()`: Entry point for core initialization, called from `mainApp.zsh`.

# Ensure these variables are available (normally defined in config.zsh)
: ${CORE_DIR:?"CORE_DIR is not defined"}
: ${UTILS_DIR:?"UTILS_DIR is not defined"}

# Load core modules
source "${CORE_DIR}/envAndCache.zsh" || { echo "Failed to load envAndCache.zsh"; exit 1; }

# Function: init_core
# Initializes the core components of the application
init_core() {
    # Side effects:
    #   - Initializes the cache and logging systems.
    #   - Loads environment variables from the `.env` file.
    #
    # Returns:
    #   0 on success, 1 on failure

    log_info "Initializing application core..."

    log_info "Initializing cache system..."
    if ! init_user_cache; then
        log_error "Failed to initialize cache system"
        return 1
    fi
    log_success "Cache system initialized successfully"

    log_info "Initializing environment..."
    if ! init_env; then
        log_error "Failed to initialize environment"
        return 1
    fi
    log_success "Environment initialized successfully"

    # Uncomment the following block if server initialization is required
    # log_info "Initializing server..."
    # if ! init_app_server; then
    #     log_error "Failed to initialize server"
    #     return 1
    # fi
    # log_success "Server initialized successfully"

    log_success "Application core initialized successfully."
    return 0
}

# Function: main_core
# Entry point for core initialization
main_core() {
    # Returns:
    #   0 on success, 1 on failure

    if init_core; then
        log_info "Core initialized successfully."
        return 0
    else
        log_error "Core initialization failed."
        return 1
    fi
}

