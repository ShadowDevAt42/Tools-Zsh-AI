import logging

# Chemin vers le fichier de log partagé
log_file = "/var/logs/zsh_copilot/copilot.log"

# Ajout du flag pour les logs Python
class OrchestratorFormatter(logging.Formatter):
    ORCHESTRATOR_FLAG = "{ORCHESTRATOR}"

    def format(self, record):
        original_message = super().format(record)
        return f"{self.ORCHESTRATOR_FLAG} {original_message}"

# Configuration du logger avec le flag {ORCHESTRATOR}
file_handler = logging.FileHandler(log_file)
file_handler.setFormatter(OrchestratorFormatter("%(asctime)s - %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S"))

logger = logging.getLogger("orchestrator_logger")
logger.setLevel(logging.DEBUG)
logger.addHandler(file_handler)

# Exemple d'utilisation
logger.info("This is an info message from the orchestrator")
logger.warning("This is a warning message from the orchestrator")
logger.error("This is an error message from the orchestrator")
logger.debug("This is a debug message from the orchestrator")
