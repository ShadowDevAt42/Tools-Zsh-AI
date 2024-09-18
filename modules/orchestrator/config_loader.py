import subprocess
import os
from dotenv import load_dotenv

def load_zsh_config(script_path):
    result = subprocess.run(f"source {script_path} && env", shell=True, capture_output=True, text=True)
    env_vars = result.stdout.splitlines()
    return dict(line.split("=", 1) for line in env_vars if "=" in line)

def load_env_config(env_file_path):
    load_dotenv(env_file_path)
    return dict(os.environ)

def merge_configs(zsh_config, env_config):
    merged_config = zsh_config.copy()
    merged_config.update(env_config)
    return merged_config

def get_config():
    # Obtenir le chemin absolu du répertoire courant (modules/orchestrator)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Remonter de deux niveaux pour atteindre la racine du projet
    root_dir = os.path.dirname(os.path.dirname(current_dir))
    
    # Définir les chemins absolus pour config.zsh et env.txt
    script_path = os.path.join(root_dir, 'config', 'config.zsh')
    env_file_path = os.path.join(root_dir, '.env')
    
    # Vérifier si les fichiers existent
    if not os.path.exists(script_path):
        raise FileNotFoundError(f"Le fichier config.zsh n'a pas été trouvé à {script_path}")
    if not os.path.exists(env_file_path):
        raise FileNotFoundError(f"Le fichier env.txt n'a pas été trouvé à {env_file_path}")
    
    # Charger les configurations
    zsh_config = load_zsh_config(script_path)
    env_config = load_env_config(env_file_path)
    
    # Fusionner les configurations
    merged_config = merge_configs(zsh_config, env_config)

    return merged_config
    
    # Ajouter le ROOT_DIR à la configuration
    merged_config['ROOT_DIR'] = root_dir
    
    return merged_config