FROM continuumio/miniconda3

RUN apt-get update && \
    apt-get install -y libosmesa6 && \
    rm -rf /var/lib/apt/lists/*

RUN conda create -n cadenv -c conda-forge \
    python=3.9 \
    cadquery=2.3 \
    pythonocc-core=7.7.0 \
    fastapi \
    uvicorn \
    ezdxf \
    -y

SHELL ["conda", "run", "-n", "cadenv", "/bin/bash", "-c"]

WORKDIR /app
COPY . .

RUN pip install httpx
RUN mkdir -p primitives temp static
RUN test -f primitives/sphere.step && test -f primitives/cylinder.step && test -f primitives/cone.step || \
    (echo "ERROR: Primitive STEP files not found in primitives/" && exit 1)

EXPOSE 8000

# Запускаем только app.py (он поднимает cut_app внутри себя)
CMD ["conda", "run", "-n", "cadenv", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
