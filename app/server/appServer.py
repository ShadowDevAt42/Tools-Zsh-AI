import sys
import os
import json
import subprocess
import traceback
import asyncio
import signal
from datetime import datetime
from typing import Dict, Any

from dotenv import load_dotenv
from unixSocketServer import UnixSocketServer
from dbServer import DbServer
from httpServer import HttpServer  # Nouvelle importation

# Color constants for logging
RED = '\033[1;31m'
ORANGE = '\033[38;5;208m'
GREEN = '\033[1;32m'
YELLOW = '\033[0;33m'
BLUE = '\033[0;34m'
PURPLE = '\033[0;35m'
PINK = '\033[38;5;205m'
NC = '\033[0m'

def print_and_log(message: str, file: str = None) -> None:
    """Print a message to console and optionally log it to a file."""
    print(message)
    if file:
        with open(file, 'a') as f:
            f.write(f"{datetime.now()}: {message}\n")

def load_zsh_config(script_path: str, log_file: str) -> Dict[str, str]:
    """Load Zsh configuration from a script file."""
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

def load_env_config(env_file_path: str, log_file: str) -> Dict[str, str]:
    """Load environment variables from a .env file."""
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

def merge_configs(zsh_config: Dict[str, str], env_config: Dict[str, str], log_file: str) -> Dict[str, str]:
    """Merge Zsh and .env configurations."""
    print_and_log("Merging configurations...", log_file)
    merged_config = zsh_config.copy()
    merged_config.update(env_config)
    print_and_log(f"Merged config keys: {', '.join(merged_config.keys())}", log_file)
    return merged_config

def get_config(log_file: str) -> Dict[str, str]:
    """Get the merged configuration from Zsh and .env files."""
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
        raise FileNotFoundError(f"Configuration script config.zsh not found at {script_path}")
    if not os.path.exists(env_file_path):
        raise FileNotFoundError(f".env file not found at {env_file_path}")
    
    try:
        zsh_config = load_zsh_config(script_path, log_file)
        env_config = load_env_config(env_file_path, log_file)
        merged_config = merge_configs(zsh_config, env_config, log_file)
        merged_config['ROOT_DIR'] = root_dir
        
        # Vérification explicite des variables de base de données
        required_db_vars = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'DB_POOL_MIN_SIZE', 'DB_POOL_MAX_SIZE']
        for var in required_db_vars:
            if var not in merged_config:
                raise KeyError(f"Required database configuration variable {var} is missing")
        
        # Log des variables de base de données (en masquant le mot de passe)
        for var in required_db_vars:
            if var == 'DB_PASSWORD':
                print_and_log(f"{var}: ********", log_file)
            else:
                print_and_log(f"{var}: {merged_config[var]}", log_file)
        
        print_and_log("Configuration loaded successfully.", log_file)
        return merged_config
    except Exception as e:
        print_and_log(f"Failed to get configuration: {e}", log_file)
        print_and_log(f"Traceback: {traceback.format_exc()}", log_file)
        raise

def signal_handler(signum: int, frame: Any) -> None:
    """Handle termination signals."""
    print_and_log("Received termination signal. Shutting down...", LOG_FILE)
    raise KeyboardInterrupt

def log_message(log_level: str, message: str, color: str) -> None:
    """Log a message with the specified level and color."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    flag = "{PYTHON}"
    log_entry = f"{color}[{timestamp}] [{log_level}] {flag} {message}{NC}\n"
    with open(LOG_FILE, "a") as log_file:
        log_file.write(log_entry)
    print(log_entry.strip())  # Also display in the console

# Define logging functions for different levels
log_info = lambda message: log_message("INFO", message, YELLOW)
log_warning = lambda message: log_message("WARNING", message, ORANGE)
log_error = lambda message: log_message("ERROR", message, RED)
log_success = lambda message: log_message("SUCCESS", message, GREEN)
log_status = lambda message: log_message("STATUS", message, BLUE)
log_debug = lambda message: log_message("DEBUG", message, PURPLE)
log_devmod = lambda message: log_message("DEVMOD", message, PINK)

async def main() -> None:
    """Main function to run the server."""
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    log_info(f"Python server started with LOG_LEVEL: {LOG_LEVEL}")
    log_info(f"Using LOG_FILE: {LOG_FILE}")
    
    # Create and start the Unix socket server
    config = get_config(LOG_FILE)
    cache_file = config.get('CACHE_FILE', '/path/to/cache/file.json')
    active_sessions_file = config.get('ACTIVE_SESSIONS_CACHE_FILE', os.path.join(config['CACHE_DIR'], 'active_sessions.json'))

    # Assurez-vous que le répertoire du cache existe
    os.makedirs(os.path.dirname(active_sessions_file), exist_ok=True)

    socket_path = config.get('SOCKET_FILE', '/tmp/zsh_copilot.sock')
    unix_socket_server = UnixSocketServer(socket_path, config, cache_file, active_sessions_file)


    
    # Create and initialize the database server with only the necessary DB config
    db_config = {
        'DB_HOST': config['DB_HOST'],
        'DB_PORT': config['DB_PORT'],
        'DB_NAME': config['DB_NAME'],
        'DB_USER': config['DB_USER'],
        'DB_PASSWORD': config['DB_PASSWORD'],
        'DB_POOL_MIN_SIZE': config['DB_POOL_MIN_SIZE'],
        'DB_POOL_MAX_SIZE': config['DB_POOL_MAX_SIZE']
    }
    db_server = DbServer(db_config)
    
    # Create the HTTP server
    http_host = config.get('HTTP_SERV_URL', 'localhost')
    http_port = int(config.get('HTTP_SERV_PORT', 8080))
    http_server = HttpServer(http_host, http_port)
    
    try:
        log_info("Initializing database connection pool")
        await db_server.init_pool()
        
        log_info("Starting Unix socket server")
        unix_socket_task = asyncio.create_task(unix_socket_server.run())    
        log_info("Starting HTTP server")
        http_server_task = asyncio.create_task(http_server.start())
        
        # Wait for both servers to complete (which they won't unless there's an error)
        await asyncio.gather(unix_socket_task, http_server_task)
    except KeyboardInterrupt:
        log_info("Received keyboard interrupt. Shutting down...")
    except Exception as e:
        log_error(f"An unexpected error occurred: {str(e)}")
        log_error(f"Traceback: {traceback.format_exc()}")
    finally:
        log_info("Closing database connection pool")
        await db_server.close_pool()
        log_info("Stopping HTTP server")
        await http_server.stop()
        log_info("Python script ended")
        print_and_log("Python script ended", initial_log_file)

if __name__ == "__main__":
    # Initialize the log file
    initial_log_file = '/tmp/python_server_init.log'
    print_and_log(f"Initializing log file: {initial_log_file}", initial_log_file)

    # Load the configuration
    try:
        config = get_config(initial_log_file)
    except Exception as e:
        print_and_log(f"Critical error loading configuration: {e}", initial_log_file)
        print_and_log("Exiting due to configuration error.", initial_log_file)
        sys.exit(1)

    # Use the loaded configurations
    LOG_DIR = config.get('LOG_DIR')
    LOG_FILE = config.get('LOG_FILE')
    LOG_LEVEL = config.get('LOG_LEVEL', 'INFO')

    print_and_log(f"LOG_DIR: {LOG_DIR}", initial_log_file)
    print_and_log(f"LOG_FILE: {LOG_FILE}", initial_log_file)
    print_and_log(f"LOG_LEVEL: {LOG_LEVEL}", initial_log_file)

    # Ensure the log directory exists
    try:
        os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
        print_and_log(f"Log directory created/verified: {os.path.dirname(LOG_FILE)}", initial_log_file)
    except Exception as e:
        print_and_log(f"Error creating log directory: {e}", initial_log_file)
        print_and_log(f"Traceback: {traceback.format_exc()}", initial_log_file)
        sys.exit(1)

    # Run the main asynchronous loop
    asyncio.run(main())