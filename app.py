rom fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, HTMLResponse
from main import app as cut_app   # <- импорт есть
import uvicorn
from pathlib import Path

app = FastAPI(title="CAD Tools Suite")

# URL сервиса вырезания (запускается на порту 8001 внутри контейнера)
CUT_SERVICE_URL = "http://localhost:8001"

# Главная страница — только работающие инструменты
HTML_INDEX = '''<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CAD Tools Suite</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: linear-gradient(135deg, #0a0c10 0%, #1a1e2a 100%);
            font-family: monospace;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container { max-width: 1200px; width: 100%; }
        h1 {
            text-align: center;
            color: #ff5500;
            font-size: 2rem;
            margin-bottom: 40px;
        }
        .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
        }
        .tool-card {
            background: rgba(15, 17, 23, 0.9);
            border: 1px solid #3a3e48;
            border-radius: 16px;
            padding: 24px;
            text-decoration: none;
            color: inherit;
            transition: all 0.3s;
        }
        .tool-card:hover {
            border-color: #ff5500;
            transform: translateY(-5px);
        }
        .tool-icon { font-size: 2.5rem; margin-bottom: 16px; }
        .tool-title { font-size: 1.3rem; font-weight: bold; margin-bottom: 8px; color: #ff5500; }
        .tool-desc { color: #9ca3b5; font-size: 0.85rem; }
        footer {
            text-align: center;
            margin-top: 48px;
            color: #6b7280;
            font-size: 0.7rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚡ CAD TOOLS SUITE</h1>
        <div class="tools-grid">
            <a href="/cut" class="tool-card">
                <div class="tool-icon">🔧</div>
                <div class="tool-title">CAD Cut Service</div>
                <div class="tool-desc">Профилирование деталей с вырезом. STEP, STL, SVG, DXF.</div>
            </a>
            <a href="/epure" class="tool-card">
                <div class="tool-icon">📏</div>
                <div class="tool-title">Эпюр Монжа</div>
                <div class="tool-desc">Трёхпроекционное черчение. Линии, прямоугольники, эллипсы.</div>
            </a>
        </div>
        <footer>CAD Tools Suite | injgaf.ru</footer>
    </div>
</body>
</html>
'''

@app.get("/", response_class=HTMLResponse)
async def root():
    return HTML_INDEX

@app.get("/epure", response_class=HTMLResponse)
async def epure_mode():
    """Отдаёт фронтенд эпюра Монжа"""
    return FileResponse("alp.html")

# Проксирование всех запросов /cut/* на внутренний сервис
@app.api_route("/cut/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def cut_proxy(request: Request, path: str):
    async with httpx.AsyncClient() as client:
        url = f"{CUT_SERVICE_URL}/{path}"
        body = await request.body()
        # Проксируем заголовки, исключая host
        headers = {k: v for k, v in request.headers.items() if k.lower() != "host"}
        resp = await client.request(
            method=request.method,
            url=url,
            headers=headers,
            content=body,
            params=request.query_params
        )
        return Response(
            content=resp.content,
            status_code=resp.status_code,
            headers=dict(resp.headers)
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
