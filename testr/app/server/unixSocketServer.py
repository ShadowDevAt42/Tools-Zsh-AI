import asyncio
import os
from typing import Tuple
from utilsServer import log_message

# Constants
BUFFER_SIZE = 1024
TIMEOUT = 60

class UnixSocketServer:
    """A Unix socket server for handling client connections."""

    def __init__(self, sock_path: str):
        """
        Initialize the UnixSocketServer.

        Args:
            sock_path (str): The path to the Unix socket file.
        """
        self.sock_path = sock_path

    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        """
        Handle a client connection.

        Args:
            reader (asyncio.StreamReader): The stream reader for the client connection.
            writer (asyncio.StreamWriter): The stream writer for the client connection.
        """
        try:
            data = await asyncio.wait_for(reader.read(BUFFER_SIZE), timeout=TIMEOUT)
            message = data.decode().strip()
            if not message:
                return

            log_message(f"Received request from Unix socket: {message}")
            
            # Respond with "pong" followed by a newline
            response = "pong\n"
            writer.write(response.encode())
            await writer.drain()
            
            log_message(f"Sent response: {response.strip()}")
        except asyncio.TimeoutError:
            log_message("Client connection timed out")
        except Exception as e:
            log_message(f"Error in handle_client: {str(e)}")
            writer.write(f"Error: {str(e)}\n".encode())
        finally:
            writer.close()
            await writer.wait_closed()

    async def run(self) -> None:
        """Run the Unix socket server."""
        if os.path.exists(self.sock_path):
            os.remove(self.sock_path)
        
        server = await asyncio.start_unix_server(self.handle_client, path=self.sock_path)
        log_message(f"Unix socket server running on {self.sock_path}")
        
        async with server:
            await server.serve_forever()

    async def ping(self) -> str:
        """
        Ping the server to check if it's running.

        Returns:
            str: "OK" if the server is running, "FAIL" otherwise.
        """
        try:
            reader, writer = await asyncio.open_unix_connection(path=self.sock_path)
            writer.close()
            await writer.wait_closed()
            return "OK"
        except Exception as e:
            log_message(f"Ping failed: {str(e)}")
            return "FAIL"