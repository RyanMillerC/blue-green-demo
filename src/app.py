from flask import Flask, render_template, send_from_directory, jsonify
import os

app = Flask(__name__)
IMAGE_DIR = os.path.join(os.path.dirname(__file__), "images")
VALID_EXTS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/images-list")
def images_list():
    if not os.path.isdir(IMAGE_DIR):
        return jsonify([])
    files = [
        f for f in os.listdir(IMAGE_DIR)
        if os.path.splitext(f)[1].lower() in VALID_EXTS
    ]
    return jsonify(sorted(files))


@app.route("/images/<path:filename>")
def serve_image(filename):
    return send_from_directory(IMAGE_DIR, filename)


if __name__ == "__main__":
    os.makedirs(IMAGE_DIR, exist_ok=True)
    app.run(host="0.0.0.0", port=5000)
