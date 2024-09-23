import aiohttp

class OllamaClient:
    def __init__(self, ollama_url, logger):
        self.ollama_url = ollama_url
        self.logger = logger

    async def get_completion(self, prompt):
        async with aiohttp.ClientSession() as session:
            async with session.post(f"{self.ollama_url}/api/generate", json={"prompt": prompt}) as response:
                if response.status == 200:
                    result = await response.json()
                    return result['response']
                else:
                    self.logger.error(f"Error from Ollama API: {response.status}")
                    return None