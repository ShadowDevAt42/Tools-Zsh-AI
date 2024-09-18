#!/bin/zsh

# Description:
#   Installation script for ZSH Copilot.
#   Installs system dependencies, Python dependencies, creates .env file,
#   and sets up default configurations.

# Source the config file
source "${0:A:h}/config/config.zsh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install system dependencies
install_system_dependencies() {
    echo "Installing system dependencies..."

    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip zsh curl jq git
    elif command_exists brew; then
        brew install python3 zsh curl jq git
    else
        echo "Unsupported package manager. Please install Python 3, Zsh, curl, jq, and git manually."
        exit 1
    fi
}

# Function to install Python dependencies
install_python_dependencies() {
    echo "Installing Python dependencies..."
    if [[ -f "${ROOT_DIR}/requirements.txt" ]]; then
        pip3 install -r "${ROOT_DIR}/requirements.txt"
    else
        echo "requirements.txt not found in ${ROOT_DIR}."
        exit 1
    fi
}

# Function to create .env file
create_env_file() {
    echo "Setting up .env file..."

    local env_file="${ROOT_DIR}/.env"

    if [[ -f "$env_file" ]]; then
        echo ".env file already exists. Do you want to overwrite it? (y/n)"
        read answer
        if [[ "$answer" != "y" ]]; then
            echo "Skipping .env file creation."
            return
        fi
    fi

    cat <<EOL > "$env_file"
# ZSH Copilot Dot Env

# API Keys
OPENAI_API_KEY="your_openai_api_key_here"
GOOGLE_API_KEY="your_google_api_key_here"
MISTRAL_API_KEY="your_mistral_api_key_here"
CLAUDE_API_KEY="your_claude_api_key_here"

# Add any other configuration variables your application needs below
# DATABASE_URL=your_database_url_here
# EXTERNAL_SERVICE_URL=https://api.example.com/v1
EOL

    echo ".env file created successfully at $env_file."
}

# Function to set default configurations in config.zsh
set_default_configurations() {
    echo "Setting default configurations in config/config.zsh..."

    local config_file="${CONFIG_DIR}/config.zsh"

    # Create a backup of the original config file
    cp "$config_file" "${config_file}.bak"

    # Replace variables with default values
    sed -i '' 's|^APP_NAME=.*|APP_NAME="ZSH Copilot"|' "$config_file"
    sed -i '' 's|^APP_VERSION=.*|APP_VERSION="1.1.0"|' "$config_file"
    sed -i '' 's|^OLLAMA_URL=.*|OLLAMA_URL="http://localhost:11434"|' "$config_file"
    sed -i '' 's|^OLLAMA_MODEL=.*|OLLAMA_MODEL="llama3.1:8b"|' "$config_file"
    sed -i '' 's|^LOG_LEVEL=.*|LOG_LEVEL="DEBUG_EX"|' "$config_file"
    sed -i '' 's|^MAX_LOG_SIZE=.*|MAX_LOG_SIZE=10485760|' "$config_file"
    sed -i '' 's|^DEFAULT_PROMPT=.*|DEFAULT_PROMPT="How can I assist you today?"|' "$config_file"
    sed -i '' 's|^MAX_HISTORY_ITEMS=.*|MAX_HISTORY_ITEMS=1000|' "$config_file"
    sed -i '' 's|^CACHE_EXPIRY=.*|CACHE_EXPIRY=86400|' "$config_file"
    sed -i '' 's|^E_GENERAL=.*|E_GENERAL=1|' "$config_file"

    echo "Default configurations set in $config_file."
}

# Main installation process
main() {
    echo "Starting installation process..."

    install_system_dependencies
    install_python_dependencies
    create_env_file
    set_default_configurations

    echo "Installation complete!"
    echo "You can now run the application using: zsh ${ROOT_DIR}/main.zsh"
}

# Run the main installation process
main
