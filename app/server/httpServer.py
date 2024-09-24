import asyncio
from aiohttp import web
from typing import Dict, Any
import json
import logging

class HttpServer:
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self.app = web.Application()
        self.app.router.add_post('/webhook', self.handle_webhook)
        self.logger = logging.getLogger(__name__)

    async def handle_webhook(self, request: web.Request) -> web.Response:
        self.logger.info(f"Requête reçue sur /webhook")
        try:
            data = await request.json()
            self.logger.info(f"Données reçues : {json.dumps(data, indent=2)}")
            
            # Traitement des données reçues
            # TODO: Ajouter le traitement spécifique ici
            
            response_data = {"status": "success", "message": "Webhook reçu et traité"}
            self.logger.info(f"Réponse envoyée : {json.dumps(response_data, indent=2)}")
            return web.json_response(response_data)
        except json.JSONDecodeError:
            self.logger.error("Erreur de décodage JSON")
            return web.json_response({"status": "error", "message": "Invalid JSON"}, status=400)
        except Exception as e:
            self.logger.error(f"Erreur lors du traitement de la requête : {str(e)}")
            return web.json_response({"status": "error", "message": str(e)}, status=500)

    async def start(self):
        runner = web.AppRunner(self.app)
        await runner.setup()
        site = web.TCPSite(runner, self.host, self.port)
        await site.start()
        self.logger.info(f"Serveur HTTP démarré sur http://{self.host}:{self.port}")

    async def stop(self):
        await self.app.shutdown()
        self.logger.info("Serveur HTTP arrêté")