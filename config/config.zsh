#!/bin/zsh

# Application name
APP_NAME="ZSH Copilot"

# Version
APP_VERSION="1.1.0"

# Paths
ROOT_DIR="${0:A:h:h}"
ORCHE_DIR="${ROOT_DIR}/modules/orchestrator"
SOCK_PATH="${ROOT_DIR}/orchestrator.sock"
CACHE_DIR="${ROOT_DIR}/cache/.zsh_copilot_cache"
LOG_DIR="${ROOT_DIR}/logs"
MODULE_DIR="${ROOT_DIR}/modules"
CONFIG_DIR="${ROOT_DIR}/config"

# Log file
LOG_FILE="${LOG_DIR}/copilot.log"
CACHE_FILE="$CACHE_DIR/user_info.json"

# Logging
LOG_LEVEL="INFO"  # Possible values: DEBUG, INFO, WARNING, ERROR
MAX_LOG_SIZE=10485760  # 10MB in bytes

# User settings
DEFAULT_PROMPT="How can I assist you today?"

# Performance
MAX_HISTORY_ITEMS=1000
CACHE_EXPIRY=86400  # 24 hours in seconds

# Load environment-specific settings
if [[ -f "${CONFIG_DIR}/env.zsh" ]]; then
    source "${CONFIG_DIR}/env.zsh"
fi

# Export variables so they're available in sourced scripts
export APP_NAME APP_VERSION ROOT_DIR CACHE_DIR LOG_DIR MODULE_DIR CONFIG_DIR LOG_FILE ORCHE_DIR SOCK_PATH
export LOG_LEVEL MAX_LOG_SIZE DEFAULT_PROMPT MAX_HISTORY_ITEMS CACHE_EXPIRY