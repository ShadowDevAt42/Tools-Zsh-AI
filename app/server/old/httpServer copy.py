from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from utilsServ import process_n8n_response, log_message

app = FastAPI()

class N8NResponse(BaseModel):
    session_number: str
    request_id: str
    result: dict

@app.post("/n8n-response")
async def n8n_response(payload: N8NResponse):
    try:
        await process_n8n_response(payload.dict())
        return {"status": "success"}
    except Exception as e:
        log_message(f"Error processing n8n response: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

def run_http_server(host, port):
    import uvicorn
    uvicorn.run(app, host=host, port=port)