import logging
import os
from enum import Enum
from datetime import datetime

class LogLevel(Enum):
    DEBUG = ('\033[0;34m', 'DEBUG')
    INFO = ('\033[0;36m', 'INFO')
    WARNING = ('\033[0;33m', 'WARNING')
    ERROR = ('\033[0;31m', 'ERROR')

class ZshCompatibleLogger:
    def __init__(self, log_file):
        self.log_file = log_file
        self.flag = "{ORCHESTRATOR}"
        self.NC = '\033[0m'  # No Color

    def _log_message(self, level: LogLevel, message: str):
        color, level_str = level.value
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"{color}[{timestamp}] [{level_str}] {self.flag} {message}{self.NC}\n"
        
        with open(self.log_file, 'a') as f:
            f.write(log_entry)

    def debug(self, message):
        self._log_message(LogLevel.DEBUG, message)

    def info(self, message):
        self._log_message(LogLevel.INFO, message)

    def warning(self, message):
        self._log_message(LogLevel.WARNING, message)

    def error(self, message):
        self._log_message(LogLevel.ERROR, message)

def get_logger(config):
    log_file = config.get('LOG_FILE')
    if not log_file:
        raise ValueError("LOG_FILE not found in configuration")

    log_dir = os.path.dirname(log_file)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    return ZshCompatibleLogger(log_file)