import asyncio
import os
from config_loader import get_config
from logger import get_logger
from socket_server import UnixSocketServer
from task_handler import TaskHandler

async def main():
    """
    The main entry point for the Orchestrator module.

    This asynchronous function performs the following tasks:
    1. Loads the configuration settings.
    2. Initializes the logger with the loaded configuration.
    3. Creates a TaskHandler instance to manage incoming tasks.
    4. Sets up a UnixSocketServer to handle client connections.
    5. Starts the UnixSocketServer and keeps it running.

    The function orchestrates the setup and execution of the main components
    of the Orchestrator module, ensuring proper initialization and startup sequence.
    It also handles logging of key events during the startup process.

    Workflow:
    - Configuration loading
    - Logger initialization
    - TaskHandler creation
    - UnixSocketServer setup
    - Server start and run

    Error Handling:
    - Any exceptions during startup will be logged and may cause the program to terminate.

    Note:
    This function is designed to be run as the main entry point of the script.
    It utilizes asyncio for asynchronous operation, allowing for efficient handling
    of multiple connections and tasks.
    """
    # Load configurations
    config = get_config()
    
    # Initialize logger
    logger = get_logger(config)
    logger.info("Configuration loaded successfully.")
    logger.debug_ex(f"Configuration details: {config}")
    
    # Initialize Task Handler
    task_handler = TaskHandler(config, logger)
    logger.info("TaskHandler initialized.")
    logger.debug_ex("TaskHandler instance created with provided configuration and logger.")
    
    # Initialize Unix Socket Server
    socket_server = UnixSocketServer(config['SOCK_PATH'], task_handler, logger)
    logger.info("UnixSocketServer initialized.")
    logger.debug_ex(f"Socket server path: {config['SOCK_PATH']}")
    
    logger.info("Starting orchestrator...")
    logger.debug_ex("Orchestrator is about to start the Unix socket server.")
    
    # Start the Unix socket server
    await socket_server.start_server()
    
    logger.success("Orchestrator has stopped running.")
    logger.debug_ex("Unix socket server has been terminated gracefully.")

if __name__ == "__main__":
    asyncio.run(main())