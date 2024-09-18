import logging
import os
from enum import Enum
from datetime import datetime

class LogLevel(Enum):
    """
    Enum representing different logging levels with associated color codes and numeric values.
    """
    ERROR = ('\033[0;31m', 'ERROR', 1)
    WARNING = ('\033[38;5;208m', 'WARNING', 2)
    INFO = ('\033[0;33m', 'INFO', 3)
    SUCCESS = ('\033[0;32m', 'SUCCESS', 4)
    DEBUG = ('\033[0;35m', 'DEBUG', 5)
    DEBUG_EX = ('\033[38;5;205m', 'DEBUG_EX', 6)

class ZshCompatibleLogger:
    """
    Custom logger compatible with Zsh's logging format.

    Attributes:
        log_file (str): Path to the log file.
        flag (str): Identifier for the logger.
        NC (str): No Color escape code.
        current_log_level (int): Numeric value of the current log level for filtering.
    """
    def __init__(self, log_file, log_level="DEBUG_EX"):
        """
        Initializes the ZshCompatibleLogger.

        Args:
            log_file (str): Path to the log file where logs will be written.
            log_level (str): The minimum severity level to log (e.g., DEBUG_EX, DEBUG, INFO, etc.).
        """
        self.log_file = log_file
        self.flag = "{ORCHESTRATOR}"
        self.NC = '\033[0m'  # No Color
        self.current_log_level = self.get_log_level_value(log_level)

    def get_log_level_value(self, level_name):
        """
        Maps log level names to numeric values.

        Args:
            level_name (str): The name of the log level.

        Returns:
            int: The numeric value corresponding to the log level.
        """
        for level in LogLevel:
            if level.name == level_name:
                return level.value[2]
        return 0  # Undefined or unknown log level

    def _log_message(self, level: LogLevel, message: str):
        """
        Logs a message with a specific severity level and color.

        Args:
            level (LogLevel): The severity level of the log.
            message (str): The message to log.
        """
        color, level_str, level_num = level.value
        if level_num <= self.current_log_level:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            log_entry = f"{color}[{timestamp}] [{level_str}] {self.flag} {message}{self.NC}\n"
            
            with open(self.log_file, 'a') as f:
                f.write(log_entry)

    def debug(self, message):
        """
        Logs a debug message.

        Args:
            message (str): The debug message to log.
        """
        self._log_message(LogLevel.DEBUG, message)

    def debug_ex(self, message):
        """
        Logs an extended debug message with detailed information.

        Args:
            message (str): The extended debug message to log.
        """
        extended_message = f"DEBUG_EX: {message}"
        self._log_message(LogLevel.DEBUG_EX, extended_message)

    def info(self, message):
        """
        Logs an informational message.

        Args:
            message (str): The informational message to log.
        """
        self._log_message(LogLevel.INFO, message)

    def success(self, message):
        """
        Logs a success message indicating successful completion of an operation.

        Args:
            message (str): The success message to log.
        """
        self._log_message(LogLevel.SUCCESS, message)

    def warning(self, message):
        """
        Logs a warning message.

        Args:
            message (str): The warning message to log.
        """
        self._log_message(LogLevel.WARNING, message)

    def error(self, message):
        """
        Logs an error message.

        Args:
            message (str): The error message to log.
        """
        self._log_message(LogLevel.ERROR, message)

def get_logger(config):
    """
    Initializes and returns a ZshCompatibleLogger instance.

    Args:
        config (dict): Configuration dictionary containing 'LOG_FILE' path and 'LOG_LEVEL'.

    Returns:
        ZshCompatibleLogger: An instance of the custom logger.
    
    Raises:
        ValueError: If 'LOG_FILE' is not found in the configuration.
    """
    log_file = config.get('LOG_FILE')
    if not log_file:
        raise ValueError("LOG_FILE not found in configuration")
    
    log_dir = os.path.dirname(log_file)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    # Initialize logger
    log_level = config.get('LOG_LEVEL', 'DEBUG_EX')  # Default to DEBUG_EX if not set
    logger = ZshCompatibleLogger(log_file, log_level)
    logger.info("Logger initialized successfully.")
    logger.debug_ex(f"Logger is set to write to {log_file} with log level: {log_level}")
    
    return logger
