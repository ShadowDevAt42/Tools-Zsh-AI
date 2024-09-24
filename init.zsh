#!/bin/zsh

# File: init.zsh

# Description:
# This script manages the initialization of system files and dependency checks for the ZSH Copilot n8n application.

source "${UTILS_DIR}/security.zsh" || { echo "Failed to load security.zsh"; return 1; }

# List of required commands for the application
REQUIRED_COMMANDS=("curl" "jq" "git" "nc")

# Function: create_directory
# Creates a directory if it doesn't exist
create_directory() {
    local dir="$1"
    [[ ! -d "$dir" ]] && mkdir -p "$dir" || return 0
}

# Function: create_file
# Creates a file if it doesn't exist
create_file() {
    local file="$1"
    [[ ! -f "$file" ]] && touch "$file" || return 0
}

# Function: rotate_log_file
# Rotates the log file and manages old log files
rotate_log_file() {
    local file="$1"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${file%.log}_${timestamp}.log"
    
    mv "$file" "$backup_file" && touch "$file" && {
        log_info "Fichier journal pivoté : $file vers $backup_file"
        
        # Supprimer les anciens fichiers journaux si dépassant MAX_LOG_FILE
        local log_count=$(ls -1 "${file%.log}"_*.log 2>/dev/null | wc -l)
        if (( log_count > MAX_LOG_FILE )); then
            ls -1t "${file%.log}"_*.log | tail -n +$((MAX_LOG_FILE+1)) | xargs rm -f
            log_info "Anciens fichiers journaux supprimés, conservation des $MAX_LOG_FILE fichiers les plus récents"
        fi
    } || return 1
}

# Function: manage_cache_file
# Manages the cache file, optionally resetting it
manage_cache_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        create_file "$file" && log_info "Fichier cache créé : $file" || return 1
    elif [[ "$CACHE_RESET_ON_START" == "true" && -s "$file" ]]; then
        : > "$file" && log_info "Fichier cache réinitialisé : $file" || return 1
    fi
}

# Function: init_sysfile
# Initializes necessary folders and files for the application
init_sysfile() {
    local dirs_to_create=("$LOG_DIR" "$CACHE_DIR")
    local log_files=("$LOG_FILE")
    local cache_files=("$CACHE_FILE")

    # Créer les répertoires
    for dir in "${dirs_to_create[@]}"; do
        create_directory "$dir" || { handle_error $E_FILESYSTEM "Échec de création du répertoire : $dir"; return 1; }
    done

    log_status "Lancement de l'application"

    # Gérer les fichiers journaux
    for file in "${log_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            create_file "$file" || { handle_error $E_FILESYSTEM "Échec de création du fichier : $file"; return 1; }
        elif [[ -s "$file" ]]; then
            rotate_log_file "$file" || { handle_error $E_FILESYSTEM "Échec de rotation du fichier journal : $file"; return 1; }
        fi
    done

    # Gérer les fichiers cache
    for file in "${cache_files[@]}"; do
        manage_cache_file "$file" || { handle_error $E_FILESYSTEM "Échec de gestion du fichier cache : $file"; return 1; }
    done

    return 0
}

# Function: check_command
# Checks if a specified command is available in the system PATH
check_command() {
    command -v $1 &> /dev/null || { log_warning "Commande non trouvée : $1"; return 1; }
}

# Function: check_dependencies
# Verifies that all required commands are available in the system
check_dependencies() {
    log_info "Vérification de toutes les dépendances"
    local missing_deps=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        check_command $cmd || missing_deps+=($cmd)
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local missing_list=$(IFS=", "; echo "${missing_deps[*]}")
        handle_error $E_DEPENDENCIES "Dépendances manquantes : $missing_list"
        return 1
    fi
    log_success "Toutes les dépendances sont satisfaites"
    return 0
}