import sys
import os
import json
import subprocess
import traceback
import asyncio
import signal
from datetime import datetime
from dotenv import load_dotenv
from unixSocketServer import UnixSocketServer

def print_and_log(message, file=None):
    print(message)
    if file:
        with open(file, 'a') as f:
            f.write(f"{datetime.now()}: {message}\n")

def load_zsh_config(script_path, log_file):
    print_and_log(f"Attempting to load Zsh config from: {script_path}", log_file)
    try:
        result = subprocess.run(f"source {script_path} && env", shell=True, capture_output=True, text=True, executable='/bin/zsh')
        if result.returncode != 0:
            raise RuntimeError(f"Error sourcing {script_path}: {result.stderr}")
        env_vars = result.stdout.splitlines()
        config = {line.split("=", 1)[0]: line.split("=", 1)[1] for line in env_vars if "=" in line}
        print_and_log(f"Zsh config loaded successfully. Keys: {', '.join(config.keys())}", log_file)
        return config
    except Exception as e:
        print_and_log(f"Failed to load Zsh configuration: {e}", log_file)
        print_and_log(f"Traceback: {traceback.format_exc()}", log_file)
        raise

def load_env_config(env_file_path, log_file):
    print_and_log(f"Attempting to load .env from: {env_file_path}", log_file)
    try:
        load_dotenv(env_file_path)
        env_config = dict(os.environ)
        print_and_log(f".env variables loaded. Keys: {', '.join(env_config.keys())}", log_file)
        return env_config
    except Exception as e:
        print_and_log(f"Failed to load environment variables from {env_file_path}: {e}", log_file)
        print_and_log(f"Traceback: {traceback.format_exc()}", log_file)
        raise

def merge_configs(zsh_config, env_config, log_file):
    print_and_log("Merging configurations...", log_file)
    merged_config = zsh_config.copy()
    merged_config.update(env_config)
    print_and_log(f"Merged config keys: {', '.join(merged_config.keys())}", log_file)
    return merged_config

def get_config(log_file):
    print_and_log("Starting configuration loading process...", log_file)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.dirname(os.path.dirname(current_dir))
    config_dir = os.path.join(root_dir, 'config')
    
    script_path = os.path.join(config_dir, 'config.zsh')
    env_file_path = os.path.join(config_dir, '.env')
    
    print_and_log(f"Root directory: {root_dir}", log_file)
    print_and_log(f"Config directory: {config_dir}", log_file)
    print_and_log(f"Zsh config path: {script_path}", log_file)
    print_and_log(f".env file path: {env_file_path}", log_file)
    
    if not os.path.exists(script_path):
        print_and_log(f"Error: Configuration script config.zsh not found at {script_path}", log_file)
        raise FileNotFoundError(f"Configuration script config.zsh not found at {script_path}")
    if not os.path.exists(env_file_path):
        print_and_log(f"Error: .env file not found at {env_file_path}", log_file)
        raise FileNotFoundError(f".env file not found at {env_file_path}")
    
    try:
        zsh_config = load_zsh_config(script_path, log_file)
        env_config = load_env_config(env_file_path, log_file)
        merged_config = merge_configs(zsh_config, env_config, log_file)
        merged_config['ROOT_DIR'] = root_dir
        print_and_log("Configuration loaded successfully.", log_file)
        return merged_config
    except Exception as e:
        print_and_log(f"Failed to get configuration: {e}", log_file)
        print_and_log(f"Traceback: {traceback.format_exc()}", log_file)
        raise

# Gestionnaire de signal pour arrêter proprement le serveur
def signal_handler(signum, frame):
    print_and_log("Received termination signal. Shutting down...", LOG_FILE)
    raise KeyboardInterrupt

# Définir les couleurs pour les logs
RED = '\033[1;31m'
ORANGE = '\033[38;5;208m'
GREEN = '\033[1;32m'
YELLOW = '\033[0;33m'
BLUE = '\033[0;34m'
PURPLE = '\033[0;35m'
PINK = '\033[38;5;205m'
NC = '\033[0m'

def log_message(log_level, message, color):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    flag = "{PYTHON}"
    log_entry = f"{color}[{timestamp}] [{log_level}] {flag} {message}{NC}\n"
    with open(LOG_FILE, "a") as log_file:
        log_file.write(log_entry)
    print(log_entry.strip())  # Afficher également dans la console

def log_info(message):
    log_message("INFO", message, YELLOW)

def log_warning(message):
    log_message("WARNING", message, ORANGE)

def log_error(message):
    log_message("ERROR", message, RED)

def log_success(message):
    log_message("SUCCESS", message, GREEN)

def log_status(message):
    log_message("STATUS", message, BLUE)

def log_debug(message):
    log_message("DEBUG", message, PURPLE)

def log_devmod(message):
    log_message("DEVMOD", message, PINK)

async def main():
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    log_info(f"Python server started with LOG_LEVEL: {LOG_LEVEL}")
    log_info(f"Using LOG_FILE: {LOG_FILE}")
    
    # Créer et démarrer le serveur de socket Unix
    socket_path = config.get('SOCKET_FILE', '/tmp/zsh_copilot.sock')
    unix_socket_server = UnixSocketServer(socket_path)
    
    try:
        log_info("Starting Unix socket server")
        await unix_socket_server.run()
    except KeyboardInterrupt:
        log_info("Received keyboard interrupt. Shutting down...")
    except Exception as e:
        log_error(f"An unexpected error occurred: {str(e)}")
        log_error(f"Traceback: {traceback.format_exc()}")
    finally:
        log_info("Python script ended")
        print_and_log("Python script ended", initial_log_file)

if __name__ == "__main__":
    # Initialiser le fichier de log
    initial_log_file = '/tmp/python_server_init.log'
    print_and_log(f"Initializing log file: {initial_log_file}", initial_log_file)

    # Charger la configuration
    try:
        config = get_config(initial_log_file)
    except Exception as e:
        print_and_log(f"Critical error loading configuration: {e}", initial_log_file)
        print_and_log("Exiting due to configuration error.", initial_log_file)
        sys.exit(1)

    # Utiliser les configurations chargées
    LOG_DIR = config.get('LOG_DIR')
    LOG_FILE = config.get('LOG_FILE')
    LOG_LEVEL = config.get('LOG_LEVEL', 'INFO')

    print_and_log(f"LOG_DIR: {LOG_DIR}", initial_log_file)
    print_and_log(f"LOG_FILE: {LOG_FILE}", initial_log_file)
    print_and_log(f"LOG_LEVEL: {LOG_LEVEL}", initial_log_file)

    # Assurez-vous que le répertoire de logs existe
    try:
        os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
        print_and_log(f"Log directory created/verified: {os.path.dirname(LOG_FILE)}", initial_log_file)
    except Exception as e:
        print_and_log(f"Error creating log directory: {e}", initial_log_file)
        print_and_log(f"Traceback: {traceback.format_exc()}", initial_log_file)
        sys.exit(1)

    # Exécuter la boucle principale asynchrone
    asyncio.run(main())