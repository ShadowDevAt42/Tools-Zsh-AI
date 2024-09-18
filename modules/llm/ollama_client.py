import requests
import json

class OllamaClient:
    def __init__(self, base_url="http://localhost:11434"):
        self.base_url = base_url

    def generate(self, prompt, model="llama2"):
        url = f"{self.base_url}/api/generate"
        data = {
            "model": model,
            "prompt": prompt
        }
        response = requests.post(url, json=data)
        if response.status_code == 200:
            return response.json()['response']
        else:
            return f"Error: {response.status_code} - {response.text}"

    def list_models(self):
        url = f"{self.base_url}/api/tags"
        response = requests.get(url)
        if response.status_code == 200:
            return [model['name'] for model in response.json()['models']]
        else:
            return f"Error: {response.status_code} - {response.text}"

# Example usage
if __name__ == "__main__":
    client = OllamaClient()
    prompt = "Tell me a joke"
    response = client.generate(prompt)
    print(f"Response: {response}")

    models = client.list_models()
    print(f"Available models: {models}")