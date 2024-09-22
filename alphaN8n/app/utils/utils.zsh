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
source "${UTILS_DIR}/cache.zsh" || { echo "Failed to load cache.zsh"; exit 1; }

# Function: get_system_info
get_system_info() {
    # Retrieves detailed system information based on the operating system.
    #
    # Logs the type of system detected and returns the system information.
    #
    # Returns:
    #   A string containing the system's version or distribution name.

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
            log_warning "Unknown operating system detected: $system_info."
            ;;
    esac
    echo "$system_info"
}

# Function: compare_and_update_cache
compare_and_update_cache() {
	# Compares the current user and system information with the cached data.
	# Updates the cache file if discrepancies are found.
	#
	# Side effects:
	#   - Logs information about the cache update process.
	#   - Writes to the cache file if changes are detected.
    local current_content=$(generate_cache_content)
    local cached_content=$(cat "$CACHE_FILE")

    if [[ "$current_content" != "$cached_content" ]]; then
        log_info "Changes detected in user information. Updating cache..."
        echo "$current_content" > "$CACHE_FILE"
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
        # Save the current buffer and cursor position
        local saved_buffer=$BUFFER
        local saved_cursor=$CURSOR

        # Clear the buffer
        BUFFER=""

        # Display "Processing..." message
        echo -ne "\rPython Server Processing..."

        # Send the input to the Python server
        local result=$(send_to_python_server "$saved_buffer")

        # Clear the "Processing..." message
        echo -ne "\r\033[K"

        if [[ -n $result ]]; then
            BUFFER="$result"
            CURSOR=${#BUFFER}
        else
            echo "No result received from Python server." >&2
            BUFFER="$saved_buffer"
            CURSOR=$saved_cursor
        fi

        zle reset-prompt
        zle redisplay
    else
        echo "Ctrl+Z pressed with empty buffer." >&2
    fi
}

# Function: update_cache_on_cd
update_cache_on_cd() {
# Updates the user cache when the current directory changes.
#
# This function is designed to be triggered by Zsh's `chpwd` mechanism.
#
# Side effects:
#   - Logs debug information about the directory change.
#   - Calls compare_and_update_cache to update the cache if necessary.
    log_debug "Directory change detected. Updating cache..."
    compare_and_update_cache
}

# Function: update_cache_on_window_change
update_cache_on_window_change() {
	# Updates the user cache when the terminal window changes.
	#
	# This function is designed to be triggered by Zsh's `precmd` mechanism.
	#
	# Side effects:
	#   - Logs debug information about the terminal window change.
	#   - Calls compare_and_update_cache to update the cache if necessary.
    log_debug "Terminal window change detected. Updating cache..."
    compare_and_update_cache
}

# Note:
# Add the following lines to your .zshrc file to enable cache updates:
# chpwd_functions=(${chpwd_functions[@]} "update_cache_on_cd")
# precmd_functions=(${precmd_functions[@]} "update_cache_on_window_change")