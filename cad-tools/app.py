"""
Unified Router for CAD Tools
"""

import os
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, HTMLResponse
import uvicorn

# Импортируем CAD Cut Service
from main import app as cut_app

app = FastAPI(title="CAD Tools Suite")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Главная страница
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
            <a href="/ortho" class="tool-card">
                <div class="tool-icon">📐</div>
                <div class="tool-title">Ortho Mode</div>
                <div class="tool-desc">Ортогональное рисование контуров. Горизонталь/вертикаль.</div>
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

@app.get("/ortho", response_class=HTMLResponse)
async def ortho_mode():
    path = Path(__file__).parent / "index.html"
    if path.exists():
        return FileResponse(path)
    raise HTTPException(404, "Not found")

@app.get("/epure", response_class=HTMLResponse)
async def epure_mode():
    path = Path(__file__).parent / "alp.html"
    if path.exists():
        return FileResponse(path)
    raise HTTPException(404, "Not found")

@app.get("/health")
async def health():
    return {"status": "ok", "services": ["cut", "ortho", "epure"]}

# Монтируем CAD Cut Service
app.mount("/cut", cut_app)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("app:app", host="0.0.0.0", port=port)