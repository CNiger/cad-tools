FROM python:3.11-slim

# Обновляем список пакетов и устанавливаем зависимости
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p temp primitives static

EXPOSE 8000

CMD ["python", "app.py"]
