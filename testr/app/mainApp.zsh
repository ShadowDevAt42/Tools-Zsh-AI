#!/bin/zsh

# File: plugin_zsh_n8n/app/mainApp.zsh

# Description:
# Fichier principal de l'application pour le projet ZSH Copilot n8n. Il gère l'initialisation, l'exécution
# et le nettoyage de l'application. Le script inclut des fonctions pour initialiser les composants principaux,
# exécuter la boucle principale de l'application, traiter les commandes utilisateur et effectuer des tâches de nettoyage.

# Chargement des composants nécessaires
source "${CORE_DIR}/mainCore.zsh" || { echo "Échec du chargement de mainCore.zsh"; return 1; }
source "${UTILS_DIR}/utils.zsh" || { echo "Échec du chargement de utils.zsh"; return 1; }
source "${SERVER_DIR}/appServer.zsh" || { echo "Échec du chargement de appServer.zsh"; return 1; }

# Gestion des signaux
handle_signal() {
    log_info "Signal de terminaison reçu. Nettoyage en cours..."
    cleanup
    return 0
}

trap handle_signal SIGINT SIGTERM

# Création d'un widget ZLE pour le gestionnaire Ctrl+Z
zle -N handle_ctrl_z
bindkey '^Z' handle_ctrl_z

# Fonction: init_app
# Initialise l'application en configurant les composants principaux
init_app() {
    log_info "Initialisation de l'application..."
    init_core || { log_error "Échec d'initialisation des composants principaux"; return 1; }
    log_success "Application initialisée avec succès"
    #start_python_server
    return 0
}

# Fonction: run_app
# Exécute la boucle principale de l'application
run_app() {
    log_info "Plugin initialisé et prêt. Appuyez sur Ctrl+Z pour afficher 'Hello World'."
    # Le plugin attend maintenant l'entrée Ctrl+Z
    
    # Boucle principale de l'application ici
    while true; do
        read -r -t 1 || continue
        # Traitement des entrées utilisateur ici
    done
    
    log_info "Application terminée"
}

# Fonction: process_command
# Traite une commande utilisateur unique
process_command() {
    local cmd="$1"
    log_info "Traitement de la commande : $cmd"
    # Ajoutez votre logique de traitement des commandes ici
}

# Fonction: cleanup
# Effectue les opérations de nettoyage nécessaires avant la terminaison de l'application
cleanup() {
    log_info "Exécution des opérations de nettoyage..."
    #stop_python_server
    # Ajoutez ici toute autre opération de nettoyage nécessaire
}

# Fonction: main_app
# Point d'entrée principal pour l'application
main_app() {
    if ! init_app; then
        log_error "Échec de l'initialisation de l'application."
        return 1
    fi
    
    log_info "Application initialisée avec succès. En attente des entrées Ctrl+Z..."
    
    # Boucle principale
    while true; do
        sleep 1
    done
}