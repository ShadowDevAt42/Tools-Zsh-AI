#!/bin/zsh

# File : main.zsh
#
# Description :
# Ce fichier sert de point d'entrée principal pour l'application ZSH Copilot n8n.
# Il initialise les configurations, le système de journalisation et les modules essentiels.
# Le script gère le cycle de vie global de l'application, y compris l'initialisation des fichiers système,
# les vérifications de dépendances et la boucle d'exécution principale.

# Chargement des fichiers source
source "${0:A:h}/config/config.zsh" || { echo "Échec du chargement de config.zsh"; return 1; }
source "${ROOT_DIR}/init.zsh" || { echo "Échec du chargement de init.zsh"; return 1; }
source "${APP_DIR}/mainApp.zsh" || { echo "Échec du chargement de mainApp.zsh"; return 1; }

# Fonction: init_main
# Initialise l'environnement de l'application
init_main() {
    echo "\033[93mStatut : Initialisation des fichiers système...\033[0m"
    init_sysfile || { handle_error $E_FILESYSTEM "Échec d'initialisation des fichiers système"; return 1; }
    echo "\033[92mSuccès : Fichiers système initialisés avec succès !\033[0m"

    echo "\033[93mStatut : Vérification de toutes les dépendances...\033[0m"
    check_dependencies || { handle_error $E_DEPENDENCIES "Dépendances manquantes"; return 1; }
    echo "\033[92mSuccès : Dépendances requises satisfaites !\033[0m"

    return 0
}

# Fonction: main
# Orchestre le cycle de vie de l'application
main() {
    init_main || { echo "Échec de l'initialisation de l'application."; return 1; }
    echo "Démarrage de main_app..."
    main_app || { echo "Échec de l'exécution de l'application."; return 1; }
    echo "Fin de main_app."
    return 0
}

# Exécution de la fonction principale
if ! main; then
    echo "Le script a rencontré un problème, mais le terminal restera ouvert."
    read -p "Appuyez sur [Entrée] pour quitter..."
fi
