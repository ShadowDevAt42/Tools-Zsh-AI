import os
import sys

# Ajoutez le chemin du module LLM au sys.path
module_dir = os.environ.get('MODULE_DIR')
if module_dir:
    llm_module_path = os.path.join(module_dir, 'llm')
    sys.path.append(llm_module_path)

from llm_handler import LLMHandler

class TaskHandler:
    def __init__(self, config, logger):
        self.logger = logger
        self.config = config
        self.llm_handler = LLMHandler(config, logger)

    async def handle_task(self, task):
        self.logger.debug(f"Handling task: {task}")
        if task == "PING":
            return "PONG"
        elif task.startswith("EXECUTE:"):
            command = task.split(":", 1)[1]
            return await self.execute_command(command)
        elif task.startswith("LLM:"):
            user_input = task.split(":", 1)[1]
            return await self.llm_handler.process_input(user_input)
        else:
            return "Unknown command"

    async def execute_command(self, command):
        self.logger.info(f"Executing command: {command}")
        try:
            result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
            return result.stdout
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Command execution failed: {e}")
            return f"Error: {e.stderr}"