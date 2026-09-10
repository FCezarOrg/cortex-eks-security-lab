FROM python:3.9-slim-bullseye

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# ==========================================================
# SECURITY DEMO ONLY
#
# Intentionally copying synthetic credentials into the image
# to demonstrate container secret detection.
# ==========================================================

COPY demo-secrets.env /app/demo-secrets.env
COPY scripts/backup.sh /app/scripts/backup.sh

RUN chmod +x /app/scripts/backup.sh

EXPOSE 8080

CMD ["python", "app.py"]
