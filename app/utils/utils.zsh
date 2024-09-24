# File: app/utils/utils.zsh

# Description:
# This file contains utility functions for the ZSH Copilot n8n application. It provides functionalities 
# for system information retrieval and cache management. These utilities help in maintaining accurate 
# system data and user context within the application.
#
# Available Functions:
# 1. `get_system_info()`: Retrieves detailed system information based on the operating system and logs the results.
# 2. `compare_and_update_cache()`: Compares current user and system information with cached data, updating the cache if changes are detected.
# 3. `update_cache_on_cd()`: Updates the user cache when the current directory changes, designed to work with Zsh's `chpwd` mechanism.
# 4. `update_cache_on_window_change()`: Updates the user cache when the terminal window changes, designed to work with Zsh's `precmd` mechanism.

# Source the cache management module
source "${UTILS_DIR}/cacheAndUser.zsh" || { echo "Failed to load cache.zsh"; return 1; }


# Function: compare_and_update_cache
compare_and_update_cache() {
    local current_content=$(generate_cache_content)
    local cached_content=$(cat "$CACHE_FILE")

    if [[ "$current_content" != "$cached_content" ]]; then
        log_info "Changes detected in user information. Updating cache..."
        echo "$current_content" > "$CACHE_FILE" || { log_error "Failed to update cache file"; return 1; }
        log_success "Cache updated successfully: $CACHE_FILE."
        log_devmod "Updated cache file content:\n$current_content"
    else
        log_info "No changes detected. Cache is up to date."
    fi
}
# Function to handle Ctrl+Z
# Function to handle Ctrl+Z
handle_ctrl_z() {
    if [[ -n $BUFFER ]]; then
        local saved_buffer=$BUFFER
        local saved_cursor=$CURSOR

        BUFFER=""
        echo -ne "\rPython Server Processing..."

        local result
        if ! result=$(send_to_python_server "$saved_buffer"); then
            log_error "Failed to send message to Python server"
            echo -ne "\r\033[K"
            BUFFER="$saved_buffer"
            CURSOR=$saved_cursor
            zle reset-prompt
            return 1
        fi

        echo -ne "\r\033[K"

        if [[ -n $result ]]; then
            BUFFER="$result"
            CURSOR=${#BUFFER}
        else
            log_warning "No result received from Python server."
            BUFFER="$saved_buffer"
            CURSOR=$saved_cursor
        fi

        zle reset-prompt
        zle redisplay
    else
        log_debug "Ctrl+Z pressed with empty buffer."
    fi
}

# Function: update_cache_on_cd
update_cache_on_cd() {
    log_debug "Directory change detected. Updating cache..."
    compare_and_update_cache
}

# Function: update_cache_on_window_change
update_cache_on_window_change() {
    log_debug "Terminal window change detected. Updating cache..."
    compare_and_update_cache
}

# Note:
# Add the following lines to your .zshrc file to enable cache updates:
# chpwd_functions=(${chpwd_functions[@]} "update_cache_on_cd")
# precmd_functions=(${precmd_functions[@]} "update_cache_on_window_change")