import aiohttp
import json

async def send_to_n8n(message):
    """
    Envoie un message à n8n et retourne la réponse.
    """
    # Remplacez l'URL par l'adresse réelle de votre serveur n8n
    n8n_url = "http://localhost:5678/webhook"
    async with aiohttp.ClientSession() as session:
        async with session.post(n8n_url, json={"message": message}) as response:
            return await response.json()

def log_message(message):
    """
    Fonction de logging (à remplacer par votre système de logging existant).
    """
    print(f"LOG: {message}")