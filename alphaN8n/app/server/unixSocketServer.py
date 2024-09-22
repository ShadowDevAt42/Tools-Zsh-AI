import asyncio
import os
import json
from utilsServer import log_message

class UnixSocketServer:
    def __init__(self, sock_path):
        self.sock_path = sock_path

    async def handle_client(self, reader, writer):
        try:
            data = await asyncio.wait_for(reader.read(1024), timeout=60)
            message = data.decode().strip()
            if not message:
                writer.close()
                await writer.wait_closed()
                return
            log_message(f"Received request from Unix socket: {message}")
            
            # Répondre avec "pong" suivi d'un saut de ligne
            response = "pong\n"
            writer.write(response.encode())
            await writer.drain()
            
            log_message(f"Sent response: {response.strip()}")
        except Exception as e:
            log_message(f"Error in handle_client: {str(e)}")
            writer.write(f"Error: {str(e)}\n".encode())
        finally:
            writer.close()
            await writer.wait_closed()

    async def run(self):
        if os.path.exists(self.sock_path):
            os.remove(self.sock_path)
        server = await asyncio.start_unix_server(self.handle_client, path=self.sock_path)
        log_message(f"Unix socket server running on {self.sock_path}")
        async with server:
            await server.serve_forever()

    async def ping(self):
        try:
            reader, writer = await asyncio.open_unix_connection(path=self.sock_path)
            writer.close()
            await writer.wait_closed()
            return "OK"
        except Exception as e:
            log_message(f"Ping failed: {str(e)}")
            return "FAIL"