import os
import sys
import subprocess

# Ajoutez le chemin du module LLM au sys.path
module_dir = os.environ.get('MODULE_DIR')
if module_dir:
    llm_module_path = os.path.join(module_dir, 'llm')
    sys.path.append(llm_module_path)

from llm_handler import LLMHandler

class TaskHandler:
    """
    A handler for processing various types of tasks.

    This class is responsible for managing different types of tasks, including
    simple ping responses, command execution, and Language Model (LLM) interactions.
    It uses a configuration object and a logger for its operations.

    Attributes:
        logger: A logging object for recording task handling activities.
        config: A configuration object containing settings for the TaskHandler.
        llm_handler: An instance of LLMHandler for processing language model tasks.
    """

    def __init__(self, config, logger):
        """
        Initialize the TaskHandler.

        Args:
            config: A configuration object containing necessary settings.
            logger: A logging object for recording task handling activities.
        """
        self.logger = logger
        self.config = config
        self.llm_handler = LLMHandler(config, logger)

    async def handle_task(self, task):
        """
        Process incoming tasks based on their type.

        This method determines the type of task from the input string and delegates
        to the appropriate handling method.

        Args:
            task (str): A string representing the task to be handled.

        Returns:
            str: The result of the task processing.

        The method supports the following task types:
        - "PING": Returns "PONG" as a simple connectivity check.
        - "EXECUTE:<command>": Executes the given shell command.
        - "LLM:<input>": Processes the input using the Language Model handler.
        - Any other input: Returns "Unknown command".
        """
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
        """
        Execute a shell command and return its output.

        This method runs the given command in a shell environment and captures
        its output. It handles both successful executions and errors.

        Args:
            command (str): The shell command to be executed.

        Returns:
            str: The output of the command if successful, or an error message if the command fails.

        Note:
            This method uses subprocess.run with shell=True, which can be a security risk
            if used with untrusted input. Ensure that the 'command' parameter is properly sanitized.
        """
        self.logger.info(f"Executing command: {command}")
        try:
            result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
            return result.stdout
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Command execution failed: {e}")
            return f"Error: {e.stderr}"