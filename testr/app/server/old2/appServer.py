# appServer.py
import asyncio
import multiprocessing
import signal
import sys
from socketServer import UnixSocketServer
from httpServer import HTTPServer
from dbServer import DatabaseServer
from utilsServer import load_config, log_message
import os

class AppServer:
    def __init__(self):
        self.config = load_config()
        self.unix_socket_path = self.config['UNIX_SOCKET_PATH']  # Ajoute cette variable dans ton .env
        self.socket_server = UnixSocketServer(self.unix_socket_path)        
        self.http_server = HTTPServer(self.config['HTTP_HOST'], self.config['HTTP_PORT'])
        self.db_server = DatabaseServer(self.config)
        self.processes = []

    async def start_servers(self):
        await self.db_server.init_db()
        
        self.processes = [
            asyncio.create_task(self.socket_server.run()),
            multiprocessing.Process(target=self.http_server.run)
        ]
        
        for process in self.processes:
            if isinstance(process, multiprocessing.Process):
                process.start()
        
        log_message("All servers started. Press CTRL+C to stop.")

    async def stop_servers(self):
        for process in self.processes:
            process.terminate()
            process.join()
        await self.db_server.close_db()
        log_message("All servers stopped.")

    async def ping_servers(self):
        socket_status = await self.socket_server.ping()
        http_status = await self.http_server.ping()
        db_status = await self.db_server.ping()
        return {
            "socket": socket_status,
            "http": http_status,
            "database": db_status
        }

def main():
    print("DB_HOST:", os.getenv("DB_HOST"))  # Cela affichera la valeur de DB_HOST
    app_server = AppServer()
    
    async def start_and_monitor():
        await app_server.start_servers()
        while True:
            statuses = await app_server.ping_servers()
            log_message(f"Server statuses: {statuses}")
            await asyncio.sleep(60)  # Ping every 60 seconds

    def signal_handler(sig, frame):
        log_message("Stopping servers...")
        asyncio.run(app_server.stop_servers())
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    asyncio.run(start_and_monitor())

if __name__ == "__main__":
    main()