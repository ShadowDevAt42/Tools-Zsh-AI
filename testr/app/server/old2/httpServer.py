# httpServer.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from utilsServer import process_n8n_response, log_message
import uvicorn

class N8NResponse(BaseModel):
    session_number: str
    request_id: str
    result: dict

class HTTPServer:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.app = FastAPI()

        @self.app.post("/n8n-response")
        async def n8n_response(payload: N8NResponse):
            try:
                await process_n8n_response(payload.dict())
                return {"status": "success"}
            except Exception as e:
                log_message(f"Error processing n8n response: {str(e)}")
                raise HTTPException(status_code=500, detail=str(e))

        @self.app.get("/ping")
        async def ping():
            return {"status": "OK"}

    def run(self):
        uvicorn.run(self.app, host=self.host, port=self.port)

    async def ping(self):
        try:
            # Use aiohttp or httpx to make an async request to the /ping endpoint
            # For simplicity, we'll just return "OK" here
            return "OK"
        except:
            return "FAIL"