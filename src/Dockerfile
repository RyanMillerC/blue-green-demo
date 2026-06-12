FROM registry.access.redhat.com/ubi9/python-311

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY templates/ templates/
COPY images/ images/

EXPOSE 5000

CMD ["python", "app.py"]
