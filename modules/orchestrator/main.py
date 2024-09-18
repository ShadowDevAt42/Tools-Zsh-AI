import asyncio
import os
from config_loader import get_config
from logger import get_logger
from socket_server import UnixSocketServer
from task_handler import TaskHandler

async def main():
    config = get_config()
    logger = get_logger(config)
    task_handler = TaskHandler(config, logger)
    socket_server = UnixSocketServer(config['SOCK_PATH'], task_handler, logger)

    logger.info("Starting orchestrator...")
    await socket_server.start_server()

if __name__ == "__main__":
    asyncio.run(main())