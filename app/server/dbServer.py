import asyncpg
from typing import Dict, Any
import logging

class DbServer:
    def __init__(self, config: Dict[str, Any]):
        required_keys = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'DB_POOL_MIN_SIZE', 'DB_POOL_MAX_SIZE']
        for key in required_keys:
            if key not in config:
                raise KeyError(f"La clé de configuration '{key}' est manquante")
        self.config = config
        self.pool = None
        self.logger = logging.getLogger(__name__)

    async def init_pool(self):
        """Initialise le pool de connexions à la base de données PostgreSQL."""
        try:
            self.pool = await asyncpg.create_pool(
                host=self.config['DB_HOST'],
                port=int(self.config['DB_PORT']),
                user=self.config['DB_USER'],
                password=self.config['DB_PASSWORD'],
                database=self.config['DB_NAME'],
                min_size=int(self.config['DB_POOL_MIN_SIZE']),
                max_size=int(self.config['DB_POOL_MAX_SIZE'])
            )
            self.logger.info("Pool de connexions PostgreSQL initialisé avec succès.")
            
            # Vérifier la connexion après l'initialisation du pool
            await self.check_connection()
        except asyncpg.PostgresError as e:
            self.logger.error(f"Erreur PostgreSQL lors de l'initialisation du pool de connexions: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Erreur inattendue lors de l'initialisation du pool de connexions PostgreSQL: {e}")
            raise

    async def check_connection(self):
        """Vérifie que la connexion au pool est établie et fonctionne correctement."""
        if not self.pool:
            self.logger.error("Le pool de connexions n'a pas été initialisé.")
            return False

        try:
            async with self.pool.acquire() as conn:
                await conn.execute('SELECT 1')
            self.logger.info("Connexion au pool PostgreSQL vérifiée avec succès.")
            return True
        except asyncpg.PostgresError as e:
            self.logger.error(f"Erreur lors de la vérification de la connexion au pool PostgreSQL: {e}")
            return False

    async def close_pool(self):
        """Ferme le pool de connexions."""
        if self.pool:
            await self.pool.close()
            self.logger.info("Pool de connexions PostgreSQL fermé.")
        else:
            self.logger.warning("Aucun pool de connexions à fermer.")

    async def execute_query(self, query: str, *args):
        """Exécute une requête SQL."""
        if not self.pool:
            raise Exception("Le pool de connexions n'a pas été initialisé.")
        
        try:
            async with self.pool.acquire() as connection:
                return await connection.fetch(query, *args)
        except asyncpg.PostgresError as e:
            self.logger.error(f"Erreur PostgreSQL lors de l'exécution de la requête: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Erreur inattendue lors de l'exécution de la requête: {e}")
            raise

# Exemple d'utilisation :
# db_server = DbServer(config)
# await db_server.init_pool()
# result = await db_server.execute_query("SELECT * FROM ma_table")
# await db_server.close_pool()