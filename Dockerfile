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

RUN pip install httpx   # не обязательно, но пусть будет
RUN mkdir -p primitives temp static

# Проверка примитивов (они создадутся в рантайме, но можно и проверить)
# Если хочешь, можешь закомментировать или оставить как предупреждение

EXPOSE 8000

CMD ["conda", "run", "-n", "cadenv", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
