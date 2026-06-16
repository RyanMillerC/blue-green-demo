import os
import random
import boto3
from fastapi import FastAPI, HTTPException
from fastapi.responses import Response

app = FastAPI()

BUCKET = os.environ.get("S3_BUCKET_NAME")

_PLACEHOLDER_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300">
  <rect width="100%" height="100%" fill="white" stroke="#aaa" stroke-width="4"/>
  <text x="50%" y="42%" text-anchor="middle" fill="#666" font-family="sans-serif" font-size="16">LOCAL DEVELOPMENT MODE</text>
  <text x="50%" y="58%" text-anchor="middle" fill="#666" font-family="sans-serif" font-size="16">S3 IMAGES DISABLED</text>
</svg>""".encode()

_NO_CACHE = {"Cache-Control": "no-store"}


def _placeholder() -> Response:
    return Response(content=_PLACEHOLDER_SVG, media_type="image/svg+xml", headers=_NO_CACHE)


def _random_image(prefix: str) -> Response:
    if not BUCKET:
        return _placeholder()
    s3 = boto3.client("s3")
    result = s3.list_objects_v2(Bucket=BUCKET, Prefix=prefix)
    objects = result.get("Contents", [])
    if not objects:
        raise HTTPException(status_code=404, detail=f"No {prefix} images found")
    key = random.choice(objects)["Key"]
    data = s3.get_object(Bucket=BUCKET, Key=key)["Body"].read()
    return Response(content=data, media_type="image/png", headers=_NO_CACHE)


@app.get("/blue")
def blue():
    return _random_image("blue-")


@app.get("/green")
def green():
    return _random_image("green-")
