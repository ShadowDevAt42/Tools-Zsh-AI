import subprocess
import os
from dotenv import load_dotenv
from logger import get_logger, ZshCompatibleLogger

def load_zsh_config(script_path):
    """
    Loads Zsh configuration by sourcing the script and capturing environment variables.

    Args:
        script_path (str): Path to the Zsh configuration script.

    Returns:
        dict: A dictionary of environment variables loaded from the Zsh script.
    
    Raises:
        RuntimeError: If sourcing the Zsh script fails.
    """
    try:
        # Use /bin/zsh to source the script and export environment variables
        result = subprocess.run(f"source {script_path} && env", shell=True, capture_output=True, text=True, executable='/bin/zsh')
        if result.returncode != 0:
            raise RuntimeError(f"Error sourcing {script_path}: {result.stderr}")
        env_vars = result.stdout.splitlines()
        config = {line.split("=", 1)[0]: line.split("=", 1)[1] for line in env_vars if "=" in line}
        return config
    except Exception as e:
        raise RuntimeError(f"Failed to load Zsh configuration: {e}")

def load_env_config(env_file_path, logger):
    """
    Loads environment variables from a .env file.

    Args:
        env_file_path (str): Path to the .env file.
        logger (ZshCompatibleLogger): Logger instance for logging.

    Returns:
        dict: A dictionary of environment variables loaded from the .env file.
    
    Raises:
        RuntimeError: If loading the .env file fails.
    """
    try:
        load_dotenv(env_file_path)
        env_config = dict(os.environ)
        logger.debug_ex(f".env variables loaded from {env_file_path}: {env_config}")
        return env_config
    except Exception as e:
        logger.error(f"Failed to load environment variables from {env_file_path}: {e}")
        raise RuntimeError(f"Failed to load environment variables from {env_file_path}: {e}")

def merge_configs(zsh_config, env_config):
    """
    Merges Zsh and .env configurations, with .env variables taking precedence.

    Args:
        zsh_config (dict): Configuration dictionary from Zsh.
        env_config (dict): Configuration dictionary from .env file.

    Returns:
        dict: Merged configuration dictionary.
    """
    merged_config = zsh_config.copy()
    merged_config.update(env_config)
    return merged_config

def get_config():
    """
    Retrieves and merges configuration from Zsh config and .env file.

    Returns:
        dict: Final merged configuration dictionary containing all necessary settings.
    
    Raises:
        FileNotFoundError: If either the Zsh config or .env file is not found.
        RuntimeError: If loading configurations fails.
    """
    # Get absolute path of the current directory (modules/orchestrator)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Navigate two levels up to reach the root directory of the project
    root_dir = os.path.dirname(os.path.dirname(current_dir))
    
    # Define absolute paths for config.zsh and .env
    script_path = os.path.join(root_dir, 'config', 'config.zsh')
    env_file_path = os.path.join(root_dir, '.env')
    
    # Initialize a temporary logger for config_loader
    temp_log_file = os.path.join(root_dir, 'logs', 'config_loader.log')
    if not os.path.exists(os.path.dirname(temp_log_file)):
        os.makedirs(os.path.dirname(temp_log_file))
    temp_logger = ZshCompatibleLogger(temp_log_file, "DEBUG_EX")
    
    # Check if the configuration files exist
    if not os.path.exists(script_path):
        temp_logger.error(f"Configuration script config.zsh not found at {script_path}")
        raise FileNotFoundError(f"Configuration script config.zsh not found at {script_path}")
    if not os.path.exists(env_file_path):
        temp_logger.error(f".env file not found at {env_file_path}")
        raise FileNotFoundError(f".env file not found at {env_file_path}")
    
    # Load configurations
    try:
        zsh_config = load_zsh_config(script_path)
        temp_logger.info("Zsh configuration loaded successfully.")
        temp_logger.debug_ex(f"Zsh Configuration: {zsh_config}")
        
        env_config = load_env_config(env_file_path, temp_logger)
        temp_logger.info(".env configuration loaded successfully.")
        
        # Merge configurations
        merged_config = merge_configs(zsh_config, env_config)
        temp_logger.debug_ex(f"Merged Configuration: {merged_config}")
        
        # Add ROOT_DIR to the configuration
        merged_config['ROOT_DIR'] = root_dir
        temp_logger.debug_ex(f"Added ROOT_DIR to configuration: {root_dir}")
        
        return merged_config
    except Exception as e:
        temp_logger.error(f"Failed to get configuration: {e}")
        raise
