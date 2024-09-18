#!/bin/zsh


# Source the config file
source "${CONFIG_DIR}/config.zsh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install system dependencies
install_system_dependencies() {
    echo "Installing system dependencies..."
    
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip zsh curl
    elif command_exists brew; then
        brew install python3 zsh curl
    else
        echo "Unsupported package manager. Please install Python 3, Zsh, and curl manually."
        exit 1
    fi
}

# Function to install Python dependencies
install_python_dependencies() {
    echo "Installing Python dependencies..."
    pip3 install requests
}

# Function to create .env file
create_env_file() {
    echo "Setting up .env file..."
    
    if [[ -f "${ROOT_DIR}/.env" ]]; then
        echo ".env file already exists. Do you want to overwrite it? (y/n)"
        read answer
        if [[ "$answer" != "y" ]]; then
            echo "Skipping .env file creation."
            return
        fi
    fi
    
    echo "Please provide the following information:"
    echo "LLM API Key (e.g., OpenAI API key):"
    read -s llm_api_key
    
    echo "LLM_API_KEY=$llm_api_key" > "${ROOT_DIR}/.env"
    echo ".env file created successfully."
}

# Main installation process
main() {
    echo "Starting installation process..."
    
    install_system_dependencies
    install_python_dependencies
    create_env_file
    
    echo "Installation complete!"
    echo "You can now run the application using: zsh ${ROOT_DIR}/main.zsh"
}

# Run the main installation process
main