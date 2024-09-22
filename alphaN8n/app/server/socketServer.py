# socketServer.py
import asyncio
import json
from utilsServer import send_to_n8n, log_message

class SocketServer:
    def __init__(self, host, port):
        self.host = host
        self.port = port

    async def handle_client(self, reader, writer):
        try:
            data = await asyncio.wait_for(reader.read(1024), timeout=60)
            message = data.decode().strip()
            if not message:
                writer.close()
                await writer.wait_closed()
                return

            log_message(f"Received request from Zsh: {message}")
            result = await send_to_n8n(message)
            
            writer.write(json.dumps(result).encode() + b'\n')
            await writer.drain()
        except Exception as e:
            log_message(f"Error in handle_client: {str(e)}")
            writer.write(f"Error: {str(e)}\n".encode())
        finally:
            writer.close()
            await writer.wait_closed()

    async def run(self):
        server = await asyncio.start_server(self.handle_client, self.host, self.port)
        log_message(f"Socket server running on {self.host}:{self.port}")
        async with server:
            await server.serve_forever()

    async def ping(self):
        try:
            _, writer = await asyncio.open_connection(self.host, self.port)
            writer.close()
            await writer.wait_closed()
            return "OK"
        except:
            return "FAIL"