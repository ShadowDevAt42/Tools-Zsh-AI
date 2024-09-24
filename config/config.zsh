# File: plugin_zsh_n8n/config/config.zsh
# Application Information
APP_NAME="ZSH Copilot n8n"
APP_VERSION="1.0.0"

# Directory Paths
ROOT_DIR="${0:A:h:h}"
LOG_DIR="${ROOT_DIR}/logs"
CONFIG_DIR="${ROOT_DIR}/config"
APP_DIR="${ROOT_DIR}/app"
CACHE_DIR="${ROOT_DIR}/cache/.zsh_copilot_cache"
UTILS_DIR="${APP_DIR}/utils"
CORE_DIR="${APP_DIR}/core"
SERVER_DIR="${APP_DIR}/server"
TEMP_DIR="${ROOT_DIR}/cache/tmp"

# File Paths
LOG_FILE="${LOG_DIR}/copilot.log"
CACHE_FILE="${CACHE_DIR}/user_cache.json"
SOCKET_FILE="${TEMP_DIR}/alpha.sock"
ACTIVE_SESSIONS_CACHE_FILE="${CACHE_DIR}/active_sessions.json"


# Logging and Cache Configuration
LOG_LEVEL=${LOG_LEVEL:-"DEVMOD"}  # Default to INFO if not set {INFO, DEBUG, DEVMOD}
HARD_LOG_LEVEL=${HARD_LOG_LEVEL:-"false"}  # Changé de "false" à "true"
MAX_LOG_FILE=${MAX_LOG_FILE:-10}
CACHE_RESET_ON_START=${CACHE_RESET_ON_START:-true}

# LLM API Configurations
LLM_USE=${LLM_USE:-"ollama"} # Default to ollama if not set {gemini, openai, mistral, claude}
MODEL_LLM_USE=${MODEL_LLM_USE:-"llama3.1:8b"}

# API Settings
OLLAMA_URL=${API_URL:-"http://localhost:8080"}  # Default port changed to a more common one
N8N_URL=${N8N_URL:-"http://localhost:5678/webhook/NyxnetGateway"}
HTTP_SERV_URL=${HTTP_SERV_URL:-"localhost"}  
HTTP_SERV_PORT=${HTTP_SERV_PORT:-"8091"}


# DB config
DB_HOST=localhost
DB_PORT=5432
DB_NAME=n8n

# Error Codes
E_GENERAL=1
E_INVALID_INPUT=2
E_FILE_NOT_FOUND=3
E_PERMISSION_DENIED=4
E_FILESYSTEM=5
E_DEPENDENCIES=6

if [[ -f "${CONFIG_DIR}/.env" ]]; then
    source "${CONFIG_DIR}/.env"
fi

# Export all variables
export APP_NAME APP_VERSION ROOT_DIR LOG_DIR CONFIG_DIR APP_DIR CACHE_DIR UTILS_DIR CORE_DIR SERVER_DIR TEMP_DIR
export LOG_FILE CACHE_FILE SOCKET_FILE LOG_LEVEL MAX_LOG_SIZE MAX_LOG_FILE CACHE_EXPIRY CACHE_RESET_ON_START ACTIVE_SESSIONS_CACHE_FILE
export LLM_USE MODEL_LLM_USE OLLAMA_URL API_URL N8N_URL DB_HOST DB_NAME DB_PORT HTTP_SERV_URL HTTP_SERV_PORT
export E_GENERAL E_INVALID_INPUT E_FILE_NOT_FOUND E_PERMISSION_DENIED E_FILESYSTEM E_DEPENDENCIES
export ZSH_COPILOT_SOCKET_HOST ZSH_COPILOT_SOCKET_PORT ZSH_COPILOT_PYTHON_SERVER_DIR

source "${UTILS_DIR}/logsAndError.zsh" || { echo "Failed to load logsAndError.zsh"; return 1; }

# Logging
hard_log_success "Configuration loaded successfully."
hard_log_info "App Name: $APP_NAME"
hard_log_info "App Version: $APP_VERSION"
hard_log_info "Log Level: $LOG_LEVEL"
hard_log_info "API URL: $API_URL"