import multiprocessing
import os
import signal
import sys
from socketServer import run_socket_server
from httpServer import run_http_server
from utilsServ import load_config, log_message

def run_server(server_func, host, port):
    asyncio.run(server_func(host, port))

def main():
    config = load_config()
    
    socket_process = multiprocessing.Process(
        target=run_server,
        args=(run_socket_server, config['SOCKET_HOST'], config['SOCKET_PORT'])
    )
    
    http_process = multiprocessing.Process(
        target=run_http_server,
        args=(config['HTTP_HOST'], config['HTTP_PORT'])
    )
    
    socket_process.start()
    http_process.start()
    
    log_message("Both servers started. Press CTRL+C to stop.")
    
    def signal_handler(sig, frame):
        log_message("Stopping servers...")
        socket_process.terminate()
        http_process.terminate()
        socket_process.join()
        http_process.join()
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    socket_process.join()
    http_process.join()

if __name__ == "__main__":
    main()