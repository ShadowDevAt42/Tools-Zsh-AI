import aiohttp
import json
from typing import Any, Dict
import logging

# Constants
N8N_URL = "http://localhost:5678/webhook"

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def send_to_n8n(message: str) -> Dict[str, Any]:
    """
    Send a message to n8n and return the response.

    Args:
        message (str): The message to send to n8n.

    Returns:
        Dict[str, Any]: The JSON response from n8n.

    Raises:
        aiohttp.ClientError: If there's an error with the HTTP request.
        json.JSONDecodeError: If the response is not valid JSON.
    """
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(N8N_URL, json={"message": message}) as response:
                response.raise_for_status()
                return await response.json()
    except aiohttp.ClientError as e:
        logger.error(f"Error sending message to n8n: {e}")
        raise
    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON response from n8n: {e}")
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