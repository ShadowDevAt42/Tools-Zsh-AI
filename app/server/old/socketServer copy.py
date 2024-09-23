import asyncio
import json
from utilsServ import send_to_n8n, log_message

async def handle_client(reader, writer):
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

async def run_socket_server(host, port):
    server = await asyncio.start_server(handle_client, host, port)
    log_message(f"Socket server running on {host}:{port}")
    async with server:
        await server.serve_forever()