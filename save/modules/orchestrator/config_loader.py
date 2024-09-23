import subprocess
import os
from dotenv import load_dotenv
from logger import get_logger, ZshCompatibleLogger

def load_zsh_config(script_path):
    """
    Loads Zsh configuration by sourcing the script and capturing environment variables.

    This function executes a Zsh script using subprocess and captures the resulting
    environment variables. It's designed to load configuration from a Zsh script
    into the Python environment.

    Args:
        script_path (str): Absolute path to the Zsh configuration script.

    Returns:
        dict: A dictionary of environment variables loaded from the Zsh script.
             Each key-value pair represents an environment variable and its value.

    Raises:
        RuntimeError: If sourcing the Zsh script fails, either due to execution
                      errors or inability to parse the output.

    Process:
    1. Executes the Zsh script using subprocess, capturing stdout and stderr.
    2. Checks for successful execution (return code 0).
    3. Parses the output to create a dictionary of environment variables.

    Note:
    - This function specifically uses /bin/zsh as the shell for script execution.
    - It assumes the Zsh script sets environment variables that can be captured.
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

    This function uses python-dotenv to load environment variables from a specified
    .env file. It enhances the process with logging for debugging and error tracking.

    Args:
        env_file_path (str): Absolute path to the .env file.
        logger (ZshCompatibleLogger): Logger instance for logging operations.

    Returns:
        dict: A dictionary of environment variables loaded from the .env file.
             Includes all variables defined in the file and any pre-existing
             environment variables.

    Raises:
        RuntimeError: If loading the .env file fails for any reason (e.g., file not
                      found, permission issues, or parsing errors).

    Process:
    1. Attempts to load the .env file using dotenv.
    2. Captures all environment variables (including those set before loading).
    3. Logs the loaded variables for debugging purposes.
    4. Handles and logs any errors encountered during the process.

    Note:
    - This function logs both successful loading and any errors encountered.
    - It captures the entire environment, not just variables defined in the .env file.
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

    This function combines two configuration dictionaries, giving priority to
    values from the .env file over those from the Zsh configuration.

    Args:
        zsh_config (dict): Configuration dictionary loaded from Zsh script.
        env_config (dict): Configuration dictionary loaded from .env file.

    Returns:
        dict: A new dictionary containing the merged configuration.

    Process:
    1. Creates a copy of the Zsh configuration.
    2. Updates this copy with values from the .env configuration.
       Any keys present in both will be overwritten by .env values.

    Note:
    - This function does not modify the original input dictionaries.
    - The resulting dictionary contains all keys from both inputs, with .env values
      overriding Zsh values where conflicts exist.
    """
    merged_config = zsh_config.copy()
    merged_config.update(env_config)
    return merged_config

def get_config():
    """
    Retrieves and merges configuration from Zsh config and .env file.

    This function serves as the main entry point for configuration loading.
    It orchestrates the process of loading configurations from both a Zsh script
    and a .env file, merging them, and preparing a final configuration dictionary.

    Returns:
        dict: Final merged configuration dictionary containing all necessary settings.

    Raises:
        FileNotFoundError: If either the Zsh config script or .env file is not found.
        RuntimeError: If loading or merging configurations fails for any reason.

    Process:
    1. Determines the project root directory and configuration file paths.
    2. Sets up a temporary logger for the configuration loading process.
    3. Verifies the existence of required configuration files.
    4. Loads Zsh configuration using load_zsh_config().
    5. Loads .env configuration using load_env_config().
    6. Merges the configurations using merge_configs().
    7. Adds the ROOT_DIR to the final configuration.

    Note:
    - The function uses a temporary logger to record the configuration loading process.
    - It assumes a specific project structure to locate configuration files.
    - The ROOT_DIR is added to the configuration for use in other parts of the application.
    - Any errors during the process are logged and re-raised for handling by the caller.
    """
    # Get absolute path of the current directory (modules/orchestrator)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Navigate two levels up to reach the root directory of the project
    root_dir = os.path.dirname(os.path.dirname(current_dir))
    
    # Define absolute paths for config.zsh and .env
    script_path = os.path.join(root_dir, 'config', 'config.zsh')
    env_file_path = os.path.join(root_dir, '.env')
    
    # Initialize a temporary logger for config_loader
    temp_log_file = os.path.join(root_dir, 'logs', 'copilot.log')
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