#!/bin/zsh

# File: plugin_zsh_n8n/config/config.zsh

# Description:
# Configuration module for the ZSH Copilot n8n application.
#
# This script defines and exports essential environment variables, paths, and settings
# used throughout the application. It serves as a central configuration point,
# allowing for easy modification of application-wide settings.
#
# Key components:
# - Application information (name, version)
# - Directory and file paths
# - Logging and cache configurations
# - LLM (Large Language Model) API settings
# - Error codes
#
# Logging and Cache Configuration:
# - LOG_LEVEL: Sets the verbosity of logging (e.g., "DEBUG_EX" for most verbose)
# - MAX_LOG_FILE: Maximum number of log files to retain during rotation
# - CACHE_RESET_ON_START: Boolean to determine if cache should be reset on application start
#
# LLM API Configurations:
# - Flags for different LLM APIs (OLLAMA, GOOGLE, MISTRAL, OPENAI, CLAUDE)
# - OLLAMA_URL: URL for the Ollama service
#
# Error Codes:
# - E_GENERAL: General error code
# - E_FILESYSTEM: File system related error code
# - E_DEPENDENCIES: Dependency-related error code
#
# Usage:
# This file should be sourced at the beginning of the application's execution.
# All variables defined here are exported and available to other scripts.
#
# Note: Sensitive information should be stored in a separate .env file and
# loaded here, rather than being hardcoded in this file.

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

# File Paths
LOG_FILE="${LOG_DIR}/copilot.log"
CACHE_FILE="${CACHE_DIR}/user_cache.json"
SOCKET_FILE="${TEMP_DIR}/alpha.sock"


# Logging and Cache Configuration
LOG_LEVEL="DEVMOD"
MAX_LOG_FILE="10"
CACHE_RESET_ON_START=true

# LLM API Configurations
OLLAMA_API="true"
GOOGLE_API="false"
MISTRAL_API="false"
OPENAI_API="false"
CLAUDE_API="false"
OLLAMA_URL="http://localhost:11434"

# API Settings
API_URL="http://localhost:...."

# Error Codes
E_GENERAL=1
E_INVALID_INPUT=2
E_FILE_NOT_FOUND=3
E_PERMISSION_DENIED=4
E_FILESYSTEM=5
E_DEPENDENCIES=6

# Socket server configuration
ZSH_COPILOT_SOCKET_HOST="127.0.0.1"
ZSH_COPILOT_SOCKET_PORT="9000"
ZSH_COPILOT_PYTHON_SERVER_DIR="${APP_DIR}/server"

# Export all variables
export APP_NAME APP_VERSION ROOT_DIR LOG_DIR CONFIG_DIR APP_DIR CACHE_DIR UTILS_DIR CORE_DIR SERVER_DIR TEMP_DIR
export LOG_FILE CACHE_FILE SOCKET_FILE LOG_LEVEL MAX_LOG_SIZE MAX_LOG_FILE CACHE_EXPIRY CACHE_RESET_ON_START
export OLLAMA_API GOOGLE_API MISTRAL_API OPENAI_API CLAUDE_API OLLAMA_URL API_URL
export E_GENERAL E_INVALID_INPUT E_FILE_NOT_FOUND E_PERMISSION_DENIED E_FILESYSTEM E_DEPENDENCIES
export ZSH_COPILOT_SOCKET_HOST ZSH_COPILOT_SOCKET_PORT ZSH_COPILOT_PYTHON_SERVER_DIR