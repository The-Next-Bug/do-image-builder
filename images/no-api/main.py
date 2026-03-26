import json
import random
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(
    title="No API",
    description="Returns a random — or specific — way to say no, with a reason.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

NOS = json.loads(Path("no.json").read_text())


class NoResponse(BaseModel):
    no: str
    reason: str


@app.get("/no", response_model=NoResponse, summary="Random no")
def get_random_no():
    """Return a randomly selected no with its reason."""
    return random.choice(NOS)


@app.get("/no/{index}", response_model=NoResponse, summary="No by index")
def get_no_by_index(index: int):
    """Return a specific no entry by zero-based index (0 to count-1)."""
    if index < 0 or index >= len(NOS):
        raise HTTPException(status_code=404, detail=f"Index out of range (0\u2013{len(NOS) - 1})")
    return NOS[index]
