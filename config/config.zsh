# config/config.zsh
#!/bin/zsh

# Description:
#   Configuration module for the application.
#   Defines essential environment variables, paths, and settings.
#   Loads environment-specific configurations and exports necessary variables for use in other modules.

# Application Information
APP_NAME="ZSH Copilot"               # Name of the application
APP_VERSION="1.1.0"                   # Current version of the application

# LLM (Large Language Model) Configurations
OLLAMA_URL="http://localhost:11434"   # URL for the Ollama service
OLLAMA_MODEL="llama3.1:8b"            # Model identifier for the LLM

# Directory Paths
ROOT_DIR="${0:A:h:h}"                             # Root directory of the application
ORCHE_DIR="${ROOT_DIR}/modules/orchestrator"       # Directory for the orchestrator module
SOCK_PATH="${ROOT_DIR}/orchestrator.sock"          # Unix socket path for orchestrator communication
CACHE_DIR="${ROOT_DIR}/cache/.zsh_copilot_cache"   # Directory for caching user information
LOG_DIR="${ROOT_DIR}/logs"                         # Directory for log files
MODULE_DIR="${ROOT_DIR}/modules"                   # Directory containing all modules
CONFIG_DIR="${ROOT_DIR}/config"                    # Directory containing configuration files

# Log Settings
LOG_FILE="${LOG_DIR}/copilot.log"  # Log file path
CACHE_FILE="${CACHE_DIR}/user_info.json"  # User information cache file path

# Logging Configuration
LOG_LEVEL="DEBUG_EX"                   # Logging level: DEBUG, INFO, WARNING, SUCCESS, ERROR, DEBUG_EX
MAX_LOG_SIZE=10485760              # Maximum log file size in bytes (10MB)

# User Settings
DEFAULT_PROMPT="How can I assist you today?"  # Default prompt for the application

# Performance Settings
MAX_HISTORY_ITEMS=1000             # Maximum number of history items
CACHE_EXPIRY=86400                 # Cache expiry time in seconds (24 hours)

# Error Codes
E_GENERAL=1                        # General error code

# Export variables to make them available in sourced scripts
export APP_NAME APP_VERSION ROOT_DIR CACHE_DIR LOG_DIR MODULE_DIR CONFIG_DIR LOG_FILE ORCHE_DIR SOCK_PATH
export LOG_LEVEL MAX_LOG_SIZE DEFAULT_PROMPT MAX_HISTORY_ITEMS CACHE_EXPIRY E_GENERAL
export OLLAMA_URL OLLAMA_MODEL

