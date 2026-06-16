FROM registry.access.redhat.com/hi/python:latest-builder AS builder
WORKDIR /app
RUN python -m venv /app/venv
COPY requirements.txt .
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM registry.access.redhat.com/hi/python:latest-fips
WORKDIR /app
COPY --from=builder /app/venv /app/venv
COPY app.py .
COPY images/ images/

EXPOSE 8080

CMD ["/app/venv/bin/uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
