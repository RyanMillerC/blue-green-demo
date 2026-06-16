import os
import random
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse

app = FastAPI()

IMAGE_DIR = os.path.join(os.path.dirname(__file__), "images")


@app.get("/blue")
def blue():
    images = [f for f in os.listdir(IMAGE_DIR) if f.startswith("blue-")]
    if not images:
        raise HTTPException(status_code=404, detail="No blue images found")
    return FileResponse(os.path.join(IMAGE_DIR, random.choice(images)), media_type="image/png", headers={"Cache-Control": "no-store"})


@app.get("/green")
def green():
    images = [f for f in os.listdir(IMAGE_DIR) if f.startswith("green-")]
    if not images:
        raise HTTPException(status_code=404, detail="No green images found")
    return FileResponse(os.path.join(IMAGE_DIR, random.choice(images)), media_type="image/png", headers={"Cache-Control": "no-store"})
