import os
import json
import aiohttp
from dotenv import load_dotenv

load_dotenv()

def load_config():
    return {
        'SOCKET_HOST': os.getenv('SOCKET_HOST', '127.0.0.1'),
        'SOCKET_PORT': int(os.getenv('SOCKET_PORT', '9000')),
        'HTTP_HOST': os.getenv('HTTP_HOST', '0.0.0.0'),
        'HTTP_PORT': int(os.getenv('HTTP_PORT', '8000')),
        'N8N_WEBHOOK_URL': os.getenv('N8N_WEBHOOK_URL', 'http://localhost:5678/webhook/zsh-webhook')
    }

def log_message(message):
    print(f"[SERVER] {message}")

async def send_to_n8n(session_number):
    config = load_config()
    async with aiohttp.ClientSession() as session:
        payload = {"session_number": session_number}
        async with session.post(config['N8N_WEBHOOK_URL'], json=payload) as resp:
            if resp.status != 200:
                raise Exception(f"Failed to send webhook to n8n, status code: {resp.status}")
            return await resp.json()

async def process_n8n_response(response):
    # Traitez la réponse de n8n ici
    log_message(f"Processed n8n response for session {response['session_number']}")
    # Vous pouvez ajouter ici une logique pour stocker ou traiter davantage la réponse