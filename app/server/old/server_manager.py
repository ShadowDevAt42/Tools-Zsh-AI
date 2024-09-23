#!/usr/bin/env python3
# File: scripts/server_manager.py

import os
import subprocess
import logging
import asyncio
import asyncpg
import psutil
import socket
import requests
from app.server.utilsServer import load_config, setup_logging

class ServerManager:
    def __init__(self):
        # Load configurations and environment variables
        self.config = load_config()
        setup_logging(self.config)
        self.logger = logging.getLogger(__name__)
        
        # Define server scripts and paths
        self.server_scripts = {
            'db_server': os.path.join('app', 'server', 'dbServer.py'),
            'http_server': os.path.join('app', 'server', 'httpServer.py'),
            'socket_server': os.path.join('app', 'server', 'socketServer.py')
        }
        
        # Server configurations
        self.unix_socket_path = self.config.get('UNIX_SOCKET_PATH', './test.sock')
        self.http_server_host = self.config.get('HTTP_SERVER_HOST', '127.0.0.1')
        self.http_server_port = int(self.config.get('HTTP_SERVER_PORT', '8000'))
        self.db_host = self.config.get('DB_HOST', 'localhost')
        self.db_port = int(self.config.get('DB_PORT', '5432'))
        self.db_user = self.config.get('DB_USER', '')
        self.db_password = self.config.get('DB_PASSWORD', '')
        self.db_name = self.config.get('DB_NAME', '')
    
    def is_server_running(self, process_name):
        # Check if a process with the given name is running
        for proc in psutil.process_iter(['name', 'cmdline']):
            if process_name in proc.info['cmdline']:
                return True
        return False

    def is_socket_server_running(self):
        # Check if Unix socket server is running by attempting to connect
        try:
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            sock.connect(self.unix_socket_path)
            sock.close()
            return True
        except socket.error:
            return False

    def is_http_server_running(self):
        # Check if HTTP server is running by sending a GET request to /ping
        try:
            response = requests.get(f"http://{self.http_server_host}:{self.http_server_port}/ping", timeout=2)
            return response.status_code == 200 and response.json().get('status') == 'OK'
        except requests.RequestException:
            return False

    async def is_db_server_running(self):
        # Check if DB server is running by attempting to connect
        try:
            conn = await asyncpg.connect(
                host=self.db_host,
                port=self.db_port,
                user=self.db_user,
                password=self.db_password,
                database=self.db_name
            )
            await conn.close()
            return True
        except:
            return False

    def start_server(self, server_name, script_path):
        # Start the server in the background, detached from the terminal
        try:
            cmd = ['nohup', 'python3', script_path]
            with open(os.devnull, 'w') as devnull:
                subprocess.Popen(cmd, stdout=devnull, stderr=devnull, preexec_fn=os.setpgrp)
            self.logger.info(f"Started {server_name}")
        except Exception as e:
            self.logger.error(f"Failed to start {server_name}: {str(e)}")

    def manage_servers(self):
        # Check and start servers as needed
        # Socket Server
        if not self.is_socket_server_running():
            script_path = os.path.join(os.getcwd(), self.server_scripts['socket_server'])
            self.start_server('socket_server', script_path)
        else:
            self.logger.info("Socket server is already running")

        # HTTP Server
        if not self.is_http_server_running():
            script_path = os.path.join(os.getcwd(), self.server_scripts['http_server'])
            self.start_server('http_server', script_path)
        else:
            self.logger.info("HTTP server is already running")

        # DB Server
        loop = asyncio.get_event_loop()
        is_db_running = loop.run_until_complete(self.is_db_server_running())
        if not is_db_running:
            script_path = os.path.join(os.getcwd(), self.server_scripts['db_server'])
            self.start_server('db_server', script_path)
        else:
            self.logger.info("DB server is already running")

    def run(self):
        self.manage_servers()

if __name__ == '__main__':
    manager = ServerManager()
    manager.run()
