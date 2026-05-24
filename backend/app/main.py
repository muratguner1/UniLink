from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import sys
import asyncio

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

from app.api.routes import student_routes
from app.api.routes import post_routes
from app.api.routes import recommendation_routes
from app.api.routes import club_routes
from app.api.routes import event_routes
from app.db.neo4j_driver import get_driver, close_driver


@asynccontextmanager
async def lifespan(app: FastAPI):
    await get_driver()
    yield
    await close_driver()


app = FastAPI(
    title="UniLink — Kampüs Sosyal Ağı API",
    description=(
        "Neo4j graph database üzerine kurulu kampüs sosyal ağı backend'i.\n\n"
        "**Özellikler:**\n"
        "- Öğrenci profili ve arkadaşlık sistemi\n"
        "- Kişiselleştirilmiş post feed'i\n"
        "- Kulüp üyelikleri ve etkinlik takibi\n"
        "- Graph tabanlı arkadaş ve etkinlik önerileri\n"
        "- shortestPath ile bağlantı zinciri bulma"
    ),
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(student_routes.router)
app.include_router(post_routes.router)
app.include_router(recommendation_routes.router)
app.include_router(club_routes.router)
app.include_router(event_routes.router)


@app.get("/", tags=["health"])
def health():
    return {
        "status": "ok",
        "service": "unilink-api",
        "version": "2.0.0",
        "endpoints": {
            "docs": "/docs",
            "redoc": "/redoc",
        },
    }
