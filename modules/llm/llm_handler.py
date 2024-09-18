import json
import aiohttp
import asyncio

class LLMHandler:
    def __init__(self, config, logger):
        self.config = config
        self.logger = logger
        self.ollama_url = config['OLLAMA_URL']
        self.ollama_model = config['OLLAMA_MODEL']

    def create_prompt(self, user_input):
        prompt = """You will be given the raw input of a shell command.
Your task is to either complete the command or provide a new command that you think the user is trying to type.
If you return a completely new command for the user, prefix it with an equal sign (=).
If you return a completion for the user's command, prefix it with a plus sign (+).
MAKE SURE TO ONLY INCLUDE THE REST OF THE COMPLETION!!!
Do not write any leading or trailing characters except if required for the completion to work.
Only respond with either a completion or a new command, not both.
Your response may only start with either a plus sign or an equal sign.
Your response MAY NOT start with both! This means that your response IS NOT ALLOWED to start with '+=' or '=+'.
You MAY explain the command by writing a short line after the comment symbol (#).
Do not ask for more information, you won't receive it.
Your response will be run in the user's shell.
Make sure input is escaped correctly if needed so.
Your input should be able to run without any modifications to it.
Don't you dare to return anything else other than a shell command!!!
DO NOT INTERACT WITH THE USER IN NATURAL LANGUAGE! If you do, you will be banned from the system.
Note that the double quote sign is escaped. Keep this in mind when you create quotes.
Here are two examples:
 * User input: 'list files in current directory'; Your response: '=ls # ls is the builtin command for listing files'
 * User input: 'cd /tm'; Your response: '+p # /tmp is the standard temp folder on linux and mac'.

User: {user_input}
Please provide a single command suggestion, prefixed with "=" for a new command or "+" for a completion. Do not provide explanations."""

        return prompt.format(user_input=user_input)

    async def process_input(self, user_input):
        self.logger.info(f"Processing user input: {user_input}")
        prompt = self.create_prompt(user_input)
        llm_response = await self.call_ollama_api(prompt, user_input)
        return self.parse_llm_response(llm_response)

    async def call_ollama_api(self, prompt, user_input):
        self.logger.debug(f"Preparing Ollama API call with input: {user_input[:50]}...")
        data = {
            "model": self.ollama_model,
            "prompt": prompt,
            "stream": False
        }
        
        animation_task = asyncio.create_task(self.animate_thinking())
        
        async with aiohttp.ClientSession() as session:
            async with session.post(f"{self.ollama_url}/api/generate", json=data) as response:
                if response.status == 200:
                    result = await response.json()
                    content = result.get('response', '')
                    self.logger.debug(f"Extracted content from Ollama response: {content[:50]}...")
                    animation_task.cancel()
                    print("\r" + " " * 50 + "\r", end="", flush=True)  # Clear the animation line
                    return content
                else:
                    self.logger.error(f"Error from Ollama API: {response.status}")
                    animation_task.cancel()
                    print("\r" + " " * 50 + "\r", end="", flush=True)  # Clear the animation line
                    return None

    async def animate_thinking(self):
        animation = ["c", "C"]
        i = 0
        try:
            while True:
                print(f"\rLLM {self.ollama_model} Thinking {''.join(animation[i % 2] for _ in range(10))}", end="", flush=True)
                i += 1
                await asyncio.sleep(0.1)
        except asyncio.CancelledError:
            pass

    def parse_llm_response(self, llm_response):
        if not llm_response:
            return "Error: Failed to get a response from the LLM."
        
        # Ensure the response starts with either '=' or '+'
        if not (llm_response.startswith('=') or llm_response.startswith('+')):
            self.logger.warning(f"Invalid LLM response format: {llm_response[:50]}...")
            return "Error: Invalid response format from LLM."
        
        # Split the response into command and comment (if present)
        parts = llm_response.split('#', 1)
        command = parts[0].strip()
        comment = parts[1].strip() if len(parts) > 1 else ""
        
        # For both new commands and completions, we return the full response
        return command