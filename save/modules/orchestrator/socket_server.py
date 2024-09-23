import asyncio
import os

class UnixSocketServer:
    """
    A Unix socket server for handling asynchronous client connections.

    This class implements a server that listens on a Unix socket for incoming
    connections. It uses asyncio for non-blocking I/O operations and delegates
    task handling to a separate TaskHandler instance.

    Attributes:
        sock_path (str): The file system path for the Unix socket.
        task_handler (TaskHandler): An instance of TaskHandler for processing client requests.
        logger (Logger): A logger instance for recording server activities.
    """

    def __init__(self, sock_path, task_handler, logger):
        """
        Initialize the UnixSocketServer.

        Args:
            sock_path (str): The file system path where the Unix socket will be created.
            task_handler (TaskHandler): An instance of TaskHandler for processing client requests.
            logger (Logger): A logger instance for recording server activities.
        """
        self.sock_path = sock_path
        self.task_handler = task_handler
        self.logger = logger

    async def handle_client(self, reader, writer):
        """
        Handle an individual client connection.

        This coroutine reads data from the client, processes it using the task handler,
        and sends a response back to the client.

        Args:
            reader (asyncio.StreamReader): A stream reader for receiving data from the client.
            writer (asyncio.StreamWriter): A stream writer for sending data to the client.

        The method performs the following steps:
        1. Read up to 100 bytes of data from the client.
        2. Decode and log the received message.
        3. Process the message using the task handler.
        4. Encode and send the response back to the client.
        5. Close the writer stream.

        Note: This method assumes that each client interaction is a single
        request-response cycle and closes the connection after sending the response.
        """
        data = await reader.read(100)
        message = data.decode().strip()
        self.logger.info(f"Received message: {message}")
        response = await self.task_handler.handle_task(message)
        writer.write(response.encode())
        await writer.drain()
        writer.close()

    async def start_server(self):
        """
        Start the Unix socket server.

        This coroutine sets up and runs the server indefinitely. It performs the following steps:
        1. Remove any existing socket file at the specified path to avoid conflicts.
        2. Create and start the Unix socket server.
        3. Log the server start event.
        4. Enter an infinite loop to keep the server running and handling connections.

        The server uses the handle_client method as a callback for each client connection.

        Note: This method will run indefinitely until interrupted or an exception occurs.
        It's designed to be the main entry point for running the server.
        """
        if os.path.exists(self.sock_path):
            os.remove(self.sock_path)
        server = await asyncio.start_unix_server(self.handle_client, path=self.sock_path)
        self.logger.info(f"Server started on {self.sock_path}")
        async with server:
            await server.serve_forever()