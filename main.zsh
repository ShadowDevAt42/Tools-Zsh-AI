#!/bin/zsh

# File : main.zsh
#
# Description :
# Ce fichier sert de point d'entrée principal pour l'application ZSH Copilot n8n.
# Il initialise les configurations, le système de journalisation et les modules essentiels.
# Le script gère l'initialisation des fichiers système et la vérification des dépendances.

# Chargement des fichiers source
source "${0:A:h}/config/config.zsh" || { echo "Échec du chargement de config.zsh"; return 1; }
source "${ROOT_DIR}/init.zsh" || { echo "Échec du chargement de init.zsh"; return 1; }
source "${APP_DIR}/mainApp.zsh" || { echo "Échec du chargement de mainApp.zsh"; return 1; }

# Function: init_main
init_main() {
	# Initializes all folders and files
	hard_log_status "Status: Initialize System File..."
    init_sysfile || { handle_error $E_FILESYSTEM "Échec d'initialisation des fichiers système"; return 1; }
    hard_log_success "Success: System files initialized successfully!"

	# Checking dependencies
	hard_log_status "Status: Checking all dependencies..."
    check_dependencies || { handle_error $E_DEPENDENCIES "Dépendances manquantes"; return 1; }
    hard_log_success "Success: Dependencies required satisfied!"
    
    return 0
}

# Function: main
main() {
    init_main || { handle_error $E_GENERAL "Échec de l'initialisation de l'application."; return 1; }
    hard_log_status "Initialisation réussie. Lancement de l'application principale..."
    main_app || { handle_error $E_GENERAL "Échec de l'initialisation de l'application."; return 1; }
}

# Exécution de la fonction principale
if ! main; then
    echo "Le script a rencontré un problème, mais le terminal restera ouvert."
    read -p "Appuyez sur [Entrée] pour quitter..."
fi
