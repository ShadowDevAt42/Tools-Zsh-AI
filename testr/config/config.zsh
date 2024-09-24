#!/bin/zsh

# File: config/config.zsh

# Description:
# Configuration module for the ZSH Copilot n8n application.
# This script defines and exports essential environment variables, paths, and settings
# used throughout the application.

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
TEMP_DIR="${CACHE_DIR}/tmp"

# Ensure critical directories exist
#mkdir -p "$LOG_DIR" "$CACHE_DIR" "$TEMP_DIR"

# File Paths
LOG_FILE="${LOG_DIR}/copilot.log"
CACHE_FILE="${CACHE_DIR}/user_cache.json"
SOCKET_FILE="${TEMP_DIR}/alpha.sock"

# Logging and Cache Configuration
LOG_LEVEL=${LOG_LEVEL:-"INFO"}  # Default to INFO if not set
MAX_LOG_FILE=${MAX_LOG_FILE:-10}
CACHE_RESET_ON_START=${CACHE_RESET_ON_START:-true}

# LLM API Configurations
OLLAMA_API=${OLLAMA_API:-"true"}
GOOGLE_API=${GOOGLE_API:-"false"}
MISTRAL_API=${MISTRAL_API:-"false"}
OPENAI_API=${OPENAI_API:-"false"}
CLAUDE_API=${CLAUDE_API:-"false"}
OLLAMA_URL=${OLLAMA_URL:-"http://localhost:11434"}

# API Settings
API_URL=${API_URL:-"http://localhost:8080"}  # Default port changed to a more common one

# Error Codes
E_GENERAL=1
E_INVALID_INPUT=2
E_FILE_NOT_FOUND=3
E_PERMISSION_DENIED=4
E_FILESYSTEM=5
E_DEPENDENCIES=6

# Socket server configuration
ZSH_COPILOT_SOCKET_HOST=${ZSH_COPILOT_SOCKET_HOST:-"127.0.0.1"}
ZSH_COPILOT_SOCKET_PORT=${ZSH_COPILOT_SOCKET_PORT:-"9000"}
ZSH_COPILOT_PYTHON_SERVER_DIR="${APP_DIR}/server"

# Load environment variables from .env file if it exists
if [[ -f "${CONFIG_DIR}/.env" ]]; then
    source "${CONFIG_DIR}/.env"
fi

# Export all variables
export APP_NAME APP_VERSION
export ROOT_DIR LOG_DIR CONFIG_DIR APP_DIR CACHE_DIR UTILS_DIR CORE_DIR SERVER_DIR TEMP_DIR
export LOG_FILE CACHE_FILE SOCKET_FILE
export LOG_LEVEL MAX_LOG_FILE CACHE_RESET_ON_START
export OLLAMA_API GOOGLE_API MISTRAL_API OPENAI_API CLAUDE_API OLLAMA_URL API_URL
export E_GENERAL E_INVALID_INPUT E_FILE_NOT_FOUND E_PERMISSION_DENIED E_FILESYSTEM E_DEPENDENCIES
export ZSH_COPILOT_SOCKET_HOST ZSH_COPILOT_SOCKET_PORT ZSH_COPILOT_PYTHON_SERVER_DIR

# Logging
echo "Configuration loaded successfully."
echo "App Name: $APP_NAME"
echo "App Version: $APP_VERSION"
echo "Log Level: $LOG_LEVEL"
echo "API URL: $API_URL"