import subprocess

class TaskHandler:
    def __init__(self, logger):
        self.logger = logger

    async def handle_task(self, task):
        self.logger.debug(f"Handling task: {task}")
        if task == "PING":
            return "PONG"
        elif task.startswith("EXECUTE:"):
            command = task.split(":", 1)[1]
            return await self.execute_command(command)
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