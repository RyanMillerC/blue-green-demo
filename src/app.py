from flask import Flask, render_template, send_from_directory
import os
import random
import importlib.util

app = Flask(__name__)
IMAGE_DIR = os.path.join(os.path.dirname(__file__), "images")
CONFIG_FILE = os.path.join(os.path.dirname(__file__), "config.py")
VALID_EXTS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}


def load_config():
    spec = importlib.util.spec_from_file_location("config", CONFIG_FILE)
    config = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(config)
    return config


@app.route("/")
def index():
    config = load_config()
    return render_template("index.html", background_color=config.BACKGROUND_COLOR)


@app.route("/frame")
def frame():
    config = load_config()
    images = []
    if os.path.isdir(IMAGE_DIR):
        images = [
            f for f in os.listdir(IMAGE_DIR)
            if f.startswith(config.IMAGE_PREFIX + "-") and os.path.splitext(f)[1].lower() in VALID_EXTS
        ]
    image = random.choice(images) if images else None
    return render_template("frame.html", image=image, background_color=config.BACKGROUND_COLOR)


@app.route("/images/<path:filename>")
def serve_image(filename):
    return send_from_directory(IMAGE_DIR, filename)


if __name__ == "__main__":
    os.makedirs(IMAGE_DIR, exist_ok=True)
    app.run(host="0.0.0.0", port=5000)
