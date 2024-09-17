#!/bin/zsh


# Initializes user data
initialize_user() {
    log_info "Checking user information..."

    if [[ ! -d "$CACHE_DIR" ]]; then
        mkdir -p "$CACHE_DIR"
        log_info "Created cache directory: $CACHE_DIR"
	else
		log_info "Cache Dir found"
    fi

    if [[ ! -f "$CACHE_FILE" ]]; then
        log_info "User cache file not found. Creating a new one..."
        create_user_cache
    else
        log_info "User cache file found. Comparing and updating if necessary..."
        compare_and_update_cache
    fi

	log_info "Checking user done"
}

# Creates a new user cache file in JSON format
create_user_cache() {
    local cache_content=$(generate_cache_content)
    echo "$cache_content" > "$CACHE_FILE"
    log_info "User cache file created successfully: $CACHE_FILE"
}

# Generates the content for the cache file
generate_cache_content() {
    local USERNAME=$(whoami)
    local SYSTEM_INFO=$(get_system_info)
    local SHELL_VERSION=$ZSH_VERSION
    local TERMINAL=$TERM
    local HOME_DIR=$HOME
    local CURRENT_DIR=$(pwd)
    local CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Uptime
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local UPTIME=$(uptime | sed 's/.*up \([^,]*\),.*/\1/')
    else
        local UPTIME=$(uptime -p 2>/dev/null || uptime | sed 's/.*up \([^,]*\),.*/\1/')
    fi
    
    # Load average
    local LOAD_AVERAGE=$(uptime | awk -F'load average:' '{ print $2 }' | sed 's/^[ \t]*//')
    
    # Available memory and disk usage
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local AVAILABLE_MEMORY=$(vm_stat | awk '/Pages free/ {free=$3} /Pages inactive/ {inactive=$3} END {print (free+inactive)*4096/1048576" MB"}' | sed 's/\./,/g')
        local DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
    else
        local AVAILABLE_MEMORY=$(free -h 2>/dev/null | awk '/^Mem:/ {print $7}' || echo "N/A")
        local DISK_USAGE=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
    fi

    cat <<EOF
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
}

# Compares the current information with the cached information
# and updates the cache if there are any differences.
compare_and_update_cache() {
    local current_content=$(generate_cache_content)
    local cached_content=$(cat "$CACHE_FILE")

    if [[ "$current_content" != "$cached_content" ]]; then
        log_info "Changes detected. Updating cache..."
        echo "$current_content" > "$CACHE_FILE"
        log_info "Cache updated successfully."
    else
        log_info "No changes detected. Cache is up to date."
    fi
}

# Function to be called when the user changes directory
update_cache_on_cd() {
    compare_and_update_cache
}

# Function to be called when the terminal window changes
update_cache_on_window_change() {
    compare_and_update_cache
}

# Add these lines to your .zshrc file:
# chpwd_functions=(${chpwd_functions[@]} "update_cache_on_cd")
# precmd_functions=(${precmd_functions[@]} "update_cache_on_window_change")