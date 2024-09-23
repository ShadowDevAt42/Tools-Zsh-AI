# dbServer.py
import asyncpg
from contextlib import asynccontextmanager
from utilsServer import log_message

class DatabaseServer:
    def __init__(self, config):
        self.config = config
        self.pool = None

    async def init_db(self):
        try:
            self.pool = await asyncpg.create_pool(
                host=self.config['DB_HOST'],
                port=self.config['DB_PORT'],
                user=self.config['DB_USER'],
                password=self.config['DB_PASSWORD'],
                database=self.config['DB_NAME'],
                min_size=self.config['DB_POOL_MIN_SIZE'],
                max_size=self.config['DB_POOL_MAX_SIZE']
            )
            log_message("Database pool created successfully")
        except Exception as e:
            log_message(f"Error creating database pool: {str(e)}")
            raise

    async def close_db(self):
        if self.pool:
            await self.pool.close()
            log_message("Database pool closed")

    @asynccontextmanager
    async def acquire(self):
        if not self.pool:
            await self.init_db()
        async with self.pool.acquire() as connection:
            yield connection

    async def execute_query(self, query, *args):
        async with self.acquire() as conn:
            return await conn.fetch(query, *args)

    async def ping(self):
        try:
            async with self.acquire() as conn:
                await conn.execute("SELECT 1")
            return "OK"
        except:
            return "FAIL"