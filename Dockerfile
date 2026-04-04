FROM continuumio/miniconda3

# Установка системной библиотеки для headless-рендеринга OpenGL
RUN apt-get update && \
    apt-get install -y libosmesa6 && \
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

# Указываем библиотеку для OSMesa
ENV OSMESA_LIBRARY=/usr/lib/x86_64-linux-gnu/libOSMesa.so.6

EXPOSE 8000

CMD ["conda", "run", "-n", "cadenv", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
