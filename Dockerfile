FROM python:3.11-slim

# Устанавливаем системные зависимости для OpenCASCADE и cadquery
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем requirements и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем всё остальное
COPY . .

# Создаём директории для временных файлов
RUN mkdir -p temp primitives static

# Открываем порт
EXPOSE 8000

# Запускаем приложение
CMD ["python", "app.py"]