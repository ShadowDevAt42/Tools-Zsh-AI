# File: app/utils/cache.zsh

# Description:
# This file contains functions for generating and managing cache content for the ZSH Copilot n8n application.
# It gathers various system and user details to maintain an up-to-date cache that reflects the current environment.

# Function: get_system_info
get_system_info() {
    log_debug "Retrieving system information..."
    local system_info

    case "$OSTYPE" in
        darwin*)
            if ! system_info=$(sw_vers 2>/dev/null | awk '{print $2}' | paste -sd "." -); then
                system_info="macOS (version retrieval failed)"
                log_warning "Failed to retrieve macOS version."
            fi
            log_debug "Detected macOS system: Version $system_info."
            ;;
        linux*)
            if [ -f /etc/os-release ]; then
                system_info=$(. /etc/os-release && echo "$PRETTY_NAME") || system_info="Linux (distribution unknown)"
            elif [ -f /etc/lsb-release ]; then
                system_info=$(. /etc/lsb-release && echo "$DISTRIB_DESCRIPTION") || system_info="Linux (distribution unknown)"
            else
                system_info="Unknown Linux distribution"
            fi
            [ "$system_info" = "Linux (distribution unknown)" ] && log_warning "Failed to determine Linux distribution."
            log_debug "Detected Linux system: $system_info."
            ;;
        *)
            system_info="Unknown operating system"
            log_warning "Unknown operating system detected: $OSTYPE"
            ;;
    esac
    echo "$system_info"
}
# Function: get_memory_info
# Retrieves available memory information based on the operating system
get_memory_info() {
    local available_memory
    if [[ "$OSTYPE" == "darwin"* ]]; then
        available_memory=$(vm_stat | awk '/Pages free/ {free=$3} /Pages inactive/ {inactive=$3} END {print (free+inactive)*4096/1048576" MB"}' | sed 's/\./,/g')
    else
        available_memory=$(free -h | awk '/^Mem:/ {print $7}')
    fi
    echo "${available_memory:-N/A}"
}

# Function: get_disk_usage
# Retrieves disk usage information for the root directory
get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}'
}
# Function: generate_cache_content
generate_cache_content() {
    local username=$(whoami)
    local system_info=$(get_system_info)
    local shell_version=$ZSH_VERSION
    local terminal=$TERM
    local home_dir=$HOME
    local current_dir=$(pwd)
    local current_time=$(date +"%Y-%m-%d %H:%M:%S")

    # Get uptime
    local uptime
    if [[ "$OSTYPE" == "darwin"* ]]; then
        uptime=$(uptime | sed 's/.*up \([^,]*\),.*/\1/')
    else
        uptime=$(uptime -p 2>/dev/null || uptime | sed 's/.*up \([^,]*\),.*/\1/')
    fi

    # Get load average
    local load_average=$(uptime | awk -F'load average:' '{ print $2 }' | sed 's/^[ \t]*//')

    # Get available memory and disk usage
    local available_memory=$(get_memory_info)
    local disk_usage=$(get_disk_usage)

    local json_content=$(cat <<EOF
{
    "username": "$username",
    "system_info": "$system_info",
    "shell_version": "$shell_version",
    "terminal": "$terminal",
    "home_directory": "$home_dir",
    "current_directory": "$current_dir",
    "current_time": "$current_time",
    "uptime": "${uptime:-N/A}",
    "load_average": "${load_average:-N/A}",
    "available_memory": "$available_memory",
    "disk_usage": "${disk_usage:-N/A}",
    "created_at": "$current_time",
    "last_updated": "$current_time"
}
EOF
)
    
    if command -v jq >/dev/null 2>&1; then
        echo "$json_content" | jq '.'
    else
        echo "$json_content"
    fi
}