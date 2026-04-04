FROM continuumio/miniconda3

# Установка системных зависимостей (libosmesa6 нужен для OCC)
RUN apt-get update && \
    apt-get install -y libosmesa6 && \
    rm -rf /var/lib/apt/lists/*

# Создаём conda-окружение со всеми зависимостями
RUN conda create -n cadenv -c conda-forge \
    python=3.9 \
    cadquery=2.3 \
    pythonocc-core=7.7.0 \
    fastapi \
    uvicorn \
    ezdxf \
    -y

# Активация окружения для всех последующих RUN и CMD
SHELL ["conda", "run", "-n", "cadenv", "/bin/bash", "-c"]

WORKDIR /app

# Копируем все файлы проекта
COPY . .

# Устанавливаем дополнительные pip-зависимости (httpx для прокси)
RUN pip install httpx

# Создаём необходимые папки
RUN mkdir -p primitives temp static

# Проверяем, что примитивы скопированы (если нет — сборка упадёт)
RUN test -f primitives/sphere.step && test -f primitives/cylinder.step && test -f primitives/cone.step || \
    (echo "ERROR: Primitive STEP files not found in primitives/" && exit 1)

# Открываем порты
EXPOSE 8000 8001

# Запускаем оба сервиса: main.py на 8001 (фоном) и app.py на 8000
# Используем bash для фонового запуска и ожидания
CMD ["bash", "-c", "conda run -n cadenv python main.py & conda run -n cadenv python app.py"]
