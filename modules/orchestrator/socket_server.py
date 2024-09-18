import asyncio
import os

class UnixSocketServer:
    def __init__(self, sock_path, task_handler, logger):
        self.sock_path = sock_path
        self.task_handler = task_handler
        self.logger = logger

    async def handle_client(self, reader, writer):
        data = await reader.read(100)
        message = data.decode().strip()
        self.logger.info(f"Received message: {message}")
        
        response = await self.task_handler.handle_task(message)
        
        writer.write(response.encode())
        await writer.drain()
        writer.close()

    async def start_server(self):
        if os.path.exists(self.sock_path):
            os.remove(self.sock_path)

        server = await asyncio.start_unix_server(self.handle_client, path=self.sock_path)
        self.logger.info(f"Server started on {self.sock_path}")

        async with server:
            await server.serve_forever()