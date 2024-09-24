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

        # Désactiver temporairement l'autosuggestion et la coloration syntaxique
        (( $+functions[_zsh_highlight_main_highlighter_disable] )) && _zsh_highlight_main_highlighter_disable
        (( $+functions[_zsh_autosuggest_disable] )) && _zsh_autosuggest_disable

        # Cacher le curseur
        echo -ne '\e[?25l'

        # Générer un nouveau message aléatoire à chaque appel
        local thinking_message=$(generate_thinking_message)
        local dots=("." ".." "..." "....")
        local dot_index=0

        # Envoyer le message au serveur Python
        send_to_python_server "$saved_buffer"

        # Attendre jusqu'à 30 secondes avec animation
        local timeout=30
        local start_time=$(date +%s)
        local current_time=$start_time
        local elapsed_time=0

        while (( elapsed_time < timeout )); do
            BUFFER="${thinking_message}${dots[$dot_index]}"
            CURSOR=${#BUFFER}
            zle reset-prompt
            zle -R

            sleep 0.5
            ((dot_index = (dot_index + 1) % 4))

            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))
        done

        # Vider le buffer après le délai
        BUFFER=""
        CURSOR=0

        # Réactiver l'autosuggestion et la coloration syntaxique
        (( $+functions[_zsh_highlight_main_highlighter_enable] )) && _zsh_highlight_main_highlighter_enable
        (( $+functions[_zsh_autosuggest_enable] )) && _zsh_autosuggest_enable

        # Afficher le curseur
        echo -ne '\e[?25h'

        # Redessiner le prompt une dernière fois
        zle reset-prompt
        zle -R
    else
        log_debug "Ctrl+Z pressed with empty buffer."
    fi
}
generate_thinking_message() {
    local messages=(
        "N8N contemplates the infinite improbability"
        "N8N delves into the cosmic abyss"
        "N8N deciphers the eldritch scrolls"
        "N8N consults the ancient tomes"
        "N8N unravels the threads of fate"
        "N8N ponders the riddles of the universe"
        "N8N gazes into the void between worlds"
        "N8N explores the realms beyond mortal ken"
        "N8N navigates the labyrinth of possibilities"
        "N8N communes with the elder gods of code"
    )
    echo ${messages[RANDOM % ${#messages[@]} + 1]}
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