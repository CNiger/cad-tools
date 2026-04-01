FROM python:3.9-slim

# Устанавливаем системные зависимости для OCCT и pythonocc-core
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1 \
    libglu1-mesa \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxcb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libxkbcommon0 \
    libfreetype6 \
    libfontconfig1 \
    libglib2.0-0 \
    libsm6 \
    libice6 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Устанавливаем pip и зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Создаём необходимые директории
RUN mkdir -p temp primitives static

EXPOSE 8000

CMD ["python", "app.py"]
