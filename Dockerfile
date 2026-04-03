FROM continuumio/miniconda3

# Установка системной библиотеки для headless-рендеринга OpenGL
RUN apt-get update && \
    apt-get install -y libosmesa8 && \
    rm -rf /var/lib/apt/lists/*

# Создание conda-окружения
RUN conda create -n cadenv -c conda-forge \
    python=3.9 \
    cadquery=2.3 \
    fastapi \
    uvicorn \
    ezdxf \
    -y

SHELL ["conda", "run", "-n", "cadenv", "/bin/bash", "-c"]

WORKDIR /app
COPY . .

RUN pip install python-multipart

# Указываем библиотеку для OSMesa (рекомендованный способ для pythonocc)
ENV OSMESA_LIBRARY=/usr/lib/x86_64-linux-gnu/libOSMesa.so.8

EXPOSE 8000

# Убедитесь, что путь к приложению верный
CMD ["conda", "run", "-n", "cadenv", "uvicorn", "app:cut_app", "--host", "0.0.0.0", "--port", "8000"]
