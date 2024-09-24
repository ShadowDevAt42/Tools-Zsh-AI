# File: app/utils/utils.zsh

# Description:
# This file contains utility functions for the ZSH Copilot n8n application. It provides functionalities 
# for system information retrieval, cache management, and handling user interactions.

# Source the cache management module
source "${UTILS_DIR}/cache.zsh" || { echo "Failed to load cache.zsh"; return 1; }

# Function: get_system_info
# Retrieves detailed system information based on the operating system
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

# Function: compare_and_update_cache
# Compares the current user and system information with the cached data
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

# Function: handle_ctrl_z
# Handles Ctrl+Z key press for interacting with the Python server
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
# Updates the user cache when the current directory changes
update_cache_on_cd() {
    log_debug "Directory change detected. Updating cache..."
    compare_and_update_cache
}

# Function: update_cache_on_window_change
# Updates the user cache when the terminal window changes
update_cache_on_window_change() {
    log_debug "Terminal window change detected. Updating cache..."
    compare_and_update_cache
}

# Export the functions
#export get_system_info compare_and_update_cache handle_ctrl_z update_cache_on_cd update_cache_on_window_change

# Note:
# Add the following lines to your .zshrc file to enable cache updates:
# chpwd_functions=(${chpwd_functions[@]} "update_cache_on_cd")
# precmd_functions=(${precmd_functions[@]} "update_cache_on_window_change")