import os
import re
import sys
import json
import base64
import random
import logging
import threading
from datetime import datetime, timedelta, timezone

import boto3
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, Response

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

_ROLE_ARN_RE = re.compile(
    r"^arn:(?:aws|aws-cn|aws-us-gov):iam::\d{12}:role/.+$"
)

_role_arn = os.environ.get("AWS_ROLE_ARN")
if _role_arn is not None:
    if not _ROLE_ARN_RE.match(_role_arn):
        logger.error("AWS_ROLE_ARN is set but invalid: %r", _role_arn)
        sys.exit(1)

app = FastAPI()

BUCKET = os.environ.get("S3_BUCKET_NAME")

_PLACEHOLDER_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300">
  <rect width="100%" height="100%" fill="white" stroke="#aaa" stroke-width="4"/>
  <text x="50%" y="42%" text-anchor="middle" fill="#666" font-family="sans-serif" font-size="16">LOCAL DEVELOPMENT MODE</text>
  <text x="50%" y="58%" text-anchor="middle" fill="#666" font-family="sans-serif" font-size="16">S3 IMAGES DISABLED</text>
</svg>""".encode()

_NO_CACHE = {"Cache-Control": "no-store"}

_s3_client = None
_s3_expiry = None
_s3_lock = threading.Lock()


def _get_s3_client():
    global _s3_client, _s3_expiry
    now = datetime.now(timezone.utc)
    with _s3_lock:
        if _s3_client is None or now >= _s3_expiry:
            region = os.environ.get("AWS_REGION", "us-gov-west-1")
            with open(os.environ["AWS_WEB_IDENTITY_TOKEN_FILE"]) as f:
                token = f.read().strip()
            sts = boto3.client("sts", region_name=region)
            resp = sts.assume_role_with_web_identity(
                RoleArn=os.environ["AWS_ROLE_ARN"],
                RoleSessionName="app",
                WebIdentityToken=token,
            )
            creds = resp["Credentials"]
            _s3_client = boto3.client(
                "s3",
                region_name=region,
                aws_access_key_id=creds["AccessKeyId"],
                aws_secret_access_key=creds["SecretAccessKey"],
                aws_session_token=creds["SessionToken"],
            )
            _s3_expiry = creds["Expiration"] - timedelta(minutes=5)
    return _s3_client


def _placeholder() -> Response:
    return Response(content=_PLACEHOLDER_SVG, media_type="image/svg+xml", headers=_NO_CACHE)


def _random_image(prefix: str) -> Response:
    if not BUCKET:
        return _placeholder()
    s3 = _get_s3_client() if os.environ.get("AWS_ROLE_ARN") else boto3.client("s3")
    result = s3.list_objects_v2(Bucket=BUCKET, Prefix=prefix)
    objects = result.get("Contents", [])
    if not objects:
        raise HTTPException(status_code=404, detail=f"No {prefix} images found")
    key = random.choice(objects)["Key"]
    data = s3.get_object(Bucket=BUCKET, Key=key)["Body"].read()
    return Response(content=data, media_type="image/png", headers=_NO_CACHE)


@app.get("/debug/aws")
def debug_aws():
    result = {}

    aws_env = {k: v for k, v in os.environ.items() if k.startswith("AWS_") or k == "S3_BUCKET_NAME"}
    result["env"] = aws_env

    token_file = os.environ.get("AWS_WEB_IDENTITY_TOKEN_FILE")
    if token_file:
        try:
            with open(token_file) as f:
                token = f.read().strip()
            padding = 4 - len(token.split(".")[1]) % 4
            claims = json.loads(base64.urlsafe_b64decode(token.split(".")[1] + "=" * padding))
            result["token"] = {"claims": claims, "readable": True}
        except Exception as e:
            result["token"] = {"readable": False, "error": str(e)}
    else:
        result["token"] = {"readable": False, "error": "AWS_WEB_IDENTITY_TOKEN_FILE not set"}

    try:
        sts = boto3.client("sts")
        identity = sts.get_caller_identity()
        result["sts"] = {"ok": True, "identity": identity}
    except Exception as e:
        result["sts"] = {"ok": False, "error": str(e)}

    try:
        s3 = boto3.client("s3")
        resp = s3.list_objects_v2(Bucket=BUCKET, MaxKeys=5)
        result["s3_auto"] = {"ok": True, "key_count": resp.get("KeyCount", 0)}
    except Exception as e:
        result["s3_auto"] = {"ok": False, "error": str(e)}

    try:
        s3 = _get_s3_client()
        resp = s3.list_objects_v2(Bucket=BUCKET, MaxKeys=5)
        result["s3_manual"] = {"ok": True, "key_count": resp.get("KeyCount", 0)}
    except Exception as e:
        result["s3_manual"] = {"ok": False, "error": str(e)}

    return JSONResponse(result)


@app.get("/blue")
def blue():
    return _random_image("blue-")


@app.get("/green")
def green():
    return _random_image("green-")
