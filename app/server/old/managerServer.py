#!/usr/bin/env python3
# server_manager.py

import asyncio
import sys
import os
import signal
import json
from appServer import AppServer

PIDFILE = '/tmp/zsh_copilot_servers.pid'
STATUSFILE = '/tmp/zsh_copilot_servers_status.json'

async def start_servers():
    app_server = AppServer()
    await app_server.start_servers()
    
    # Enregistrer le PID
    with open(PIDFILE, 'w') as f:
        f.write(str(os.getpid()))
    
    # Boucle pour maintenir les serveurs actifs
    while True:
        statuses = await app_server.ping_servers()
        with open(STATUSFILE, 'w') as f:
            json.dump(statuses, f)
        await asyncio.sleep(60)

def stop_servers():
    try:
        with open(PIDFILE, 'r') as f:
            pid = int(f.read().strip())
        os.kill(pid, signal.SIGTERM)
        os.remove(PIDFILE)
        os.remove(STATUSFILE)
        print("Servers stopped.")
    except FileNotFoundError:
        print("Servers are not running.")
    except ProcessLookupError:
        print("Servers process not found. Cleaning up files.")
        os.remove(PIDFILE)
        os.remove(STATUSFILE)

def check_status():
    if os.path.exists(STATUSFILE):
        with open(STATUSFILE, 'r') as f:
            statuses = json.load(f)
        print("Server statuses:")
        for server, status in statuses.items():
            print(f"{server}: {status}")
    else:
        print("Servers are not running.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: server_manager.py [start|stop|status]")
        sys.exit(1)

    command = sys.argv[1]
    if command == "start":
        asyncio.run(start_servers())
    elif command == "stop":
        stop_servers()
    elif command == "status":
        check_status()
    else:
        print("Unknown command. Use start, stop, or status.")
        sys.exit(1)