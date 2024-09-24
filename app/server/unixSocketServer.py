import asyncio
import os
import json
from typing import Tuple
from utilsServer import log_message, send_to_n8n, update_cache_file, ensure_file_exists
import aiofiles


class UnixSocketServer:
    def __init__(self, sock_path: str, config: dict, cache_file: str, active_sessions_file: str):
        self.sock_path = sock_path
        self.config = config
        self.cache_file = cache_file
        self.active_sessions_file = active_sessions_file
        self.initialize_active_sessions_file()

    def initialize_active_sessions_file(self):
        ensure_file_exists(self.active_sessions_file, {"active_tasks": {}})
        log_message(f"Initialized active sessions file: {self.active_sessions_file}")

    async def update_active_sessions_with_session(self, session_id: str):
        try:
            ensure_file_exists(self.active_sessions_file, {"active_tasks": {}})
            
            async with aiofiles.open(self.active_sessions_file, 'r') as f:
                active_sessions = json.loads(await f.read())
            
            task_id = f"task_{len(active_sessions['active_tasks']) + 1}"
            active_sessions['active_tasks'][task_id] = session_id
            
            await update_cache_file(self.active_sessions_file, active_sessions)
            log_message(f"Updated active sessions with new task: {task_id}")
        except Exception as e:
            log_message(f"Error updating active sessions with session: {str(e)}")


    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        try:
            data = await asyncio.wait_for(reader.read(1024), timeout=60)
            message = data.decode().strip()
            if not message:
                return

            log_message(f"Received request from Unix socket: {message}")
            
            response = await self.process_message(message)
            
            writer.write(response.encode())
            await writer.drain()
            
            log_message(f"Sent response: {response}")
        except Exception as e:
            log_message(f"Error in handle_client: {str(e)}")
        finally:
            writer.close()
            await writer.wait_closed()

    async def process_message(self, message: str) -> str:
        try:
            cache_info = self.get_cache_info()
            
            payload = {
                "workflowRoad": {
                    "workflow": "llm",
                    "function": "cmdZsh"
                },
                "config": {
                    "llmUse": self.config.get('LLM_USE', 'ollama'),
                    "llmModelUse": self.config.get('MODEL_LLM_USE', 'llama3.1:8b')
                },
                "userInput": {
                    "userMessage": message,
                    "userSystem": cache_info.get('system_info', 'Unknown'),
                    "shell_version": cache_info.get('shell_version', 'Unknown'),
                    "current_directory": cache_info.get('current_directory', 'Unknown')
                }
            }

            n8n_response = await send_to_n8n(self.config['N8N_URL'], payload)
            
            if 'sessionId' in n8n_response:
                await self.update_active_sessions_with_session(n8n_response['sessionId'])
            
            # Ne rien renvoyer
            return ""
        except Exception as e:
            log_message(f"Error processing message: {str(e)}")
            return ""  # Même en cas d'erreur, ne rien renvoyer

    def get_cache_info(self) -> dict:
        try:
            with open(self.cache_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            log_message(f"Error reading cache file: {str(e)}")
            return {}

    async def update_active_sessions_with_session(self, session_id: str):
        try:
            with open(self.active_sessions_file, 'r') as f:
                active_sessions = json.load(f)
            
            task_id = f"task_{len(active_sessions['active_tasks']) + 1}"
            active_sessions['active_tasks'][task_id] = session_id
            
            await update_cache_file(self.active_sessions_file, active_sessions)
        except Exception as e:
            log_message(f"Error updating active sessions with session: {str(e)}")

    async def run(self) -> None:
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