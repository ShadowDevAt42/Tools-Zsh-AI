import logging
import os
from enum import Enum
from datetime import datetime

class LogLevel(Enum):
    """
    Enum representing different logging levels with associated color codes and numeric values.
    
    Each log level is defined as a tuple containing:
    - Color code (string): ANSI escape sequence for console color output
    - Level name (string): Textual representation of the log level
    - Numeric value (int): Integer value for log level comparison and filtering
    
    Available log levels:
    - ERROR: Critical errors that may cause program termination
    - WARNING: Potential issues that don't prevent program execution
    - INFO: General information about program execution
    - SUCCESS: Successful completion of important operations
    - DEBUG: Detailed information for debugging purposes
    - DEBUG_EX: Extended debugging information with extra details
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
    
    This logger provides methods for logging messages at different severity levels,
    with color-coded output and timestamps. It writes logs to a specified file and
    filters messages based on the current log level.
    
    Attributes:
        log_file (str): Path to the log file where messages are written.
        flag (str): Identifier for the logger, appended to each log message.
        NC (str): ANSI escape sequence to reset text color.
        current_log_level (int): Numeric value of the current log level for filtering messages.
    
    Methods:
        debug, debug_ex, info, success, warning, error: Log messages at respective levels.
        _log_message: Internal method to format and write log entries.
        get_log_level_value: Convert log level names to their numeric values.
    """
    def __init__(self, log_file, log_level="DEBUG_EX"):
        """
        Initialize the ZshCompatibleLogger.
        
        Args:
            log_file (str): Path to the file where logs will be written.
            log_level (str): The minimum severity level to log (default: "DEBUG_EX").
                             Only messages at this level and higher will be logged.
        
        The logger is set up with the specified log file and level. It creates
        the log directory if it doesn't exist and initializes internal attributes.
        """
        self.log_file = log_file
        self.flag = "{ORCHESTRATOR}"
        self.NC = '\033[0m'  # No Color
        self.current_log_level = self.get_log_level_value(log_level)

    def get_log_level_value(self, level_name):
        """
        Map log level names to their corresponding numeric values.
        
        Args:
            level_name (str): The name of the log level (e.g., "DEBUG", "INFO").
        
        Returns:
            int: The numeric value corresponding to the log level.
                 Returns 0 for undefined or unknown log levels.
        
        This method allows for dynamic filtering of log messages based on
        their severity level.
        """
        for level in LogLevel:
            if level.name == level_name:
                return level.value[2]
        return 0  # Undefined or unknown log level

    def _log_message(self, level: LogLevel, message: str):
        """
        Format and write a log message to the log file.
        
        Args:
            level (LogLevel): The severity level of the log message.
            message (str): The content of the log message.
        
        This internal method handles the actual writing of log entries. It
        applies color coding, adds timestamps, and filters messages based on
        the current log level. Messages are appended to the log file.
        """
        color, level_str, level_num = level.value
        if level_num <= self.current_log_level:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            log_entry = f"{color}[{timestamp}] [{level_str}] {self.flag} {message}{self.NC}\n"
            
            with open(self.log_file, 'a') as f:
                f.write(log_entry)

    def debug(self, message):
        """
        Log a debug message.
        
        Args:
            message (str): The debug message to log.
        
        Logs detailed information useful for debugging purposes.
        """
        self._log_message(LogLevel.DEBUG, message)

    def debug_ex(self, message):
        """
        Log an extended debug message with extra details.
        
        Args:
            message (str): The extended debug message to log.
        
        Used for logging highly detailed debug information, including stack traces,
        variable states, or complex operations' intermediate results.
        """
        extended_message = f"DEBUG_EX: {message}"
        self._log_message(LogLevel.DEBUG_EX, extended_message)

    def info(self, message):
        """
        Log an informational message.
        
        Args:
            message (str): The informational message to log.
        
        Used for general information about the program's execution state.
        """
        self._log_message(LogLevel.INFO, message)

    def success(self, message):
        """
        Log a success message.
        
        Args:
            message (str): The success message to log.
        
        Indicates successful completion of important operations or milestones.
        """
        self._log_message(LogLevel.SUCCESS, message)

    def warning(self, message):
        """
        Log a warning message.
        
        Args:
            message (str): The warning message to log.
        
        Used for potentially problematic situations that don't prevent program execution.
        """
        self._log_message(LogLevel.WARNING, message)

    def error(self, message):
        """
        Log an error message.
        
        Args:
            message (str): The error message to log.
        
        Used for critical errors that may lead to program malfunction or termination.
        """
        self._log_message(LogLevel.ERROR, message)

def get_logger(config):
    """
    Initialize and return a ZshCompatibleLogger instance.
    
    Args:
        config (dict): Configuration dictionary containing 'LOG_FILE' path and 'LOG_LEVEL'.
    
    Returns:
        ZshCompatibleLogger: An instance of the custom logger, configured and ready to use.
    
    Raises:
        ValueError: If 'LOG_FILE' is not found in the configuration.
    
    This function sets up the logging environment, creates necessary directories,
    and initializes the logger with the specified configuration. It also logs
    initial messages to confirm successful logger setup.
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