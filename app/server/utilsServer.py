import aiohttp
import json
from typing import Any, Dict
import logging
import aiofiles
import os

def ensure_file_exists(file_path: str, default_content: dict = {}):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)
        log_message(f"Created directory: {directory}")
    
    if not os.path.exists(file_path):
        with open(file_path, 'w') as f:
            json.dump(default_content, f, indent=2)
        log_message(f"Created file with default content: {file_path}")

async def update_cache_file(cache_file: str, content: dict):
    async with aiofiles.open(cache_file, 'w') as f:
        await f.write(json.dumps(content, indent=2))
    log_message(f"Updated cache file: {cache_file}")

def delete_file_if_exists(file_path: str):
    if os.path.exists(file_path):
        os.remove(file_path)
        log_message(f"Deleted file: {file_path}")
# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def send_to_n8n(n8n_url: str, payload: Dict[str, Any]) -> Dict[str, Any]:
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(n8n_url, json=payload) as response:
                response.raise_for_status()
                return await response.json()
    except aiohttp.ClientError as e:
        logging.error(f"Error sending message to n8n: {e}")
        raise
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding JSON response from n8n: {e}")
        raise

def log_message(message: str, level: str = "INFO") -> None:
    """
    Log a message using the configured logger.

    Args:
        message (str): The message to log.
        level (str): The log level (default is "INFO").
    """
    log_levels = {
        "DEBUG": logging.DEBUG,
        "INFO": logging.INFO,
        "WARNING": logging.WARNING,
        "ERROR": logging.ERROR,
        "CRITICAL": logging.CRITICAL
    }
    log_level = log_levels.get(level.upper(), logging.INFO)
    logger.log(log_level, message)

# Example usage of the logging function:
# log_message("This is a debug message", "DEBUG")
# log_message("This is an info message")
# log_message("This is a warning message", "WARNING")
# log_message("This is an error message", "ERROR")
# log_message("This is a critical message", "CRITICAL")