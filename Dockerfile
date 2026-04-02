FROM continuumio/miniconda3

# Создаём окружение со всеми зависимостями
RUN conda create -n cadenv -c conda-forge \
    python=3.9 \
    cadquery=2.3 \
    fastapi \
    uvicorn \
    ezdxf \
    -y

# Активируем окружение для всех последующих RUN / CMD
SHELL ["conda", "run", "-n", "cadenv", "/bin/bash", "-c"]

WORKDIR /app

COPY . .

# (опционально) если нужен python-multipart
RUN pip install python-multipart

EXPOSE 8000

# ВАЖНО: замените app:cut_app на правильную точку входа
# Если ваш главный app лежит в main.py и называется app → main:app
# Если у вас app.py и внутри from main import app as cut_app → app:cut_app
CMD ["conda", "run", "-n", "cadenv", "uvicorn", "app:cut_app", "--host", "0.0.0.0", "--port", "8000"]
