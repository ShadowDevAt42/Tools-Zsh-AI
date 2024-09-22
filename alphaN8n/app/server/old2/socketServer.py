import asyncio
import os
import json
from utilsServer import send_to_n8n, log_message

class UnixSocketServer:
    """
    Un serveur de socket Unix pour gérer les connexions clientes asynchrones.
    """

    def __init__(self, sock_path):
        """
        Initialise le serveur de socket Unix.

        Args:
            sock_path (str): Le chemin du fichier socket Unix.
        """
        self.sock_path = sock_path

    async def handle_client(self, reader, writer):
        """
        Gère une connexion client individuelle.

        Args:
            reader (asyncio.StreamReader): Un lecteur pour recevoir les données du client.
            writer (asyncio.StreamWriter): Un écrivain pour envoyer des données au client.
        """
        try:
            data = await asyncio.wait_for(reader.read(1024), timeout=60)
            message = data.decode().strip()
            if not message:
                writer.close()
                await writer.wait_closed()
                return

            log_message(f"Received request from Unix socket: {message}")
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
        """
        Démarre le serveur de socket Unix.
        """
        if os.path.exists(self.sock_path):
            os.remove(self.sock_path)  # Supprime l'ancien socket si nécessaire
        server = await asyncio.start_unix_server(self.handle_client, path=self.sock_path)
        log_message(f"Unix socket server running on {self.sock_path}")
        async with server:
            await server.serve_forever()  # Attendre l'exécution du serveur

    async def ping(self):
        """
        Vérifie si le serveur Unix socket est accessible.
        """
        try:
            reader, writer = await asyncio.open_unix_connection(path=self.sock_path)
            writer.close()
            await writer.wait_closed()
            return "OK"
        except Exception as e:
            log_message(f"Ping failed: {str(e)}")
            return "FAIL"
