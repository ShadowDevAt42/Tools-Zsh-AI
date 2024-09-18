import asyncio
import os
from config_loader import get_config
from logger import get_logger
from socket_server import UnixSocketServer
from task_handler import TaskHandler

async def main():
    """
    The main entry point for the Orchestrator module.

    Initializes configurations, logger, task handler, and Unix socket server.
    Starts the Unix socket server to listen for incoming connections.
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
