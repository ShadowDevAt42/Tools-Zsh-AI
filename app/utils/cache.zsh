# File: app/utils/cache.zsh

# Description:
# This file contains functions for generating and managing cache content for the ZSH Copilot n8n application.
# It gathers various system and user details to maintain an up-to-date cache that reflects the current environment.
#
# Available Functions:
# 1. `generate_cache_content()`: Collects detailed user and system information and returns a JSON-formatted string 
#    representing the cache content.

# Function: generate_cache_content
generate_cache_content() {
	# Gathers various user and system information to generate the cache content.
	#
	# Side effects:
	#   - Uses system-specific commands to collect information.
	#   - Logs warnings or errors if certain information cannot be retrieved.
	#
	# Returns:
	#   A JSON-formatted string containing user and system details.
	#
	# Note:
	#   This function uses system-specific commands and may need adjustment
	#   for different operating systems or environments.
    local USERNAME=$(whoami)
    local SYSTEM_INFO=$(get_system_info)
    local SHELL_VERSION=$ZSH_VERSION
    local TERMINAL=$TERM
    local HOME_DIR=$HOME
    local CURRENT_DIR=$(pwd)
    local CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

    # Uptime
    local UPTIME
    if [[ "$OSTYPE" == "darwin"* ]]; then
        UPTIME=$(uptime | sed 's/.*up \([^,]*\),.*/\1/' 2>/dev/null || echo "N/A")
    else
        UPTIME=$(uptime -p 2>/dev/null || uptime | sed 's/.*up \([^,]*\),.*/\1/' 2>/dev/null || echo "N/A")
    fi

    # Load average
    local LOAD_AVERAGE=$(uptime | awk -F'load average:' '{ print $2 }' | sed 's/^[ \t]*//' 2>/dev/null || echo "N/A")

    # Available memory and disk usage
    local AVAILABLE_MEMORY
    local DISK_USAGE
    if [[ "$OSTYPE" == "darwin"* ]]; then
        AVAILABLE_MEMORY=$(vm_stat 2>/dev/null | awk '/Pages free/ {free=$3} /Pages inactive/ {inactive=$3} END {print (free+inactive)*4096/1048576" MB"}' | sed 's/\./,/g' || echo "N/A")
        DISK_USAGE=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
    else
        AVAILABLE_MEMORY=$(free -h 2>/dev/null | awk '/^Mem:/ {print $7}' || echo "N/A")
        DISK_USAGE=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
    fi

    local json_content=$(cat <<EOF
{
    "username": "$USERNAME",
    "system_info": "$SYSTEM_INFO",
    "shell_version": "$SHELL_VERSION",
    "terminal": "$TERMINAL",
    "home_directory": "$HOME_DIR",
    "current_directory": "$CURRENT_DIR",
    "current_time": "$CURRENT_TIME",
    "uptime": "$UPTIME",
    "load_average": "$LOAD_AVERAGE",
    "available_memory": "$AVAILABLE_MEMORY",
    "disk_usage": "$DISK_USAGE",
    "created_at": "$CURRENT_TIME",
    "last_updated": "$CURRENT_TIME"
}
EOF
)
    
    if command -v jq >/dev/null 2>&1; then
        echo "$json_content" | jq '.'
    else
        echo "$json_content"
    fi
}