#!/bin/zsh

# File : main.zsh
#
# Description :
# This file serves as the main entry point for the ZSH Copilot n8n application.
# It initializes configurations, the logging system, and essential modules.
# The script manages the overall lifecycle of the application, including system file initialization,
# dependency checks, and the main execution loop.
#
# Key Components :
# - System file initialization
# - Dependency checking
# - Application launch
#
# Available Functions :
# 1. init_main() :
#    - Initializes the application environment by setting up system files and checking dependencies.
#    - Side effects :
#        - Initializes system files using the init_sysfile function.
#        - Checks required dependencies using the check_dependencies function.
#        - Logs the initialization status.
#        - Handles errors using the handle_error function.
#    - Returns :
#        - 0 on success, 1 on failure.

# 2. main() :
#    - Orchestrates the application's lifecycle by initializing the application and calling the main application logic.
#    - Side effects :
#        - Calls init_main to initialize the application.
#        - Calls main_app to run the main application logic.
#        - Logs errors if initialization or execution fails.
#        - Exits the script with an error code on failure.
#
# Error Handling :
# - Uses the handle_error function for consistent error management.
# - Exits with error code 1 on critical failures.
#
# Usage :
# This script should be executed to start the ZSH Copilot n8n application.

# Source file
source "${0:A:h}/config/config.zsh" || { echo "Failed to load config.zsh"; exit 1; }
source "${ROOT_DIR}/init.zsh" || { echo "Failed to load init.zsh"; exit 1; }
source "${APP_DIR}/mainApp.zsh" || { echo "Failed to load mainApp.zsh"; exit 1; }

# Function: init_main
init_main() {
	# Initializes all floders and files
	echo "\033[93mStatus: Initialize System File...\033[0m"
    if ! init_sysfile; then
        handle_error $E_FILESYSTEM "Failed to initialize system files"
        return 1
    fi
    echo "\033[92mSuccess: System files initialized successfully!\033[0m"

	# Checking dependencies
	echo "\033[93mStatus: Checking all dependencies...\033[0m"
    if ! check_dependencies; then
        handle_error $E_DEPENDENCIES "Missing dependencies"
        return 1
    fi
    echo "\033[92mSuccess: Dependencies required satisfied!\033[0m"
    return 0
}

# Function: main
main() {
    if ! init_main; then
        log_error "Application initialization failed."
        return 1
    fi

    if ! main_app; then
        log_error "Application execution failed."
        return 1
    fi
	return 0
}
# Exécute la fonction main
if ! main; then
    echo "The script encountered an issue, but the terminal will remain open."
    read -p "Press [Enter] to exit..."  # Garde le terminal ouvert jusqu'à ce que l'utilisateur appuie sur Enter
fi
