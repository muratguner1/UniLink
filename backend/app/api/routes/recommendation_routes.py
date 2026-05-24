from fastapi import APIRouter, HTTPException, Query
from app.models.models import RecommendationOut, EventOut, ConnectionPath, DepartmentStat
from app.services.recommendation_service import RecommendationService

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("/{studentId}/friends", response_model=list[RecommendationOut])
async def recommend_friends(
    studentId: str,
    limit: int = Query(default=10, ge=1, le=50),
):
    """Arkadaş önerileri: ortak arkadaş + ortak kulüp skoru."""
    records = await RecommendationService.get_friend_recommendations(studentId, limit)
    return [RecommendationOut(**dict(r)) for r in records]


@router.get("/{studentId}/events", response_model=list[EventOut])
async def recommend_events(studentId: str):
    """Kulüp bazlı etkinlik önerileri."""
    records = await RecommendationService.get_event_recommendations(studentId)
    return [EventOut(**dict(r)) for r in records]


@router.get("/path/{fromId}/{toId}", response_model=ConnectionPath)
async def connection_path(fromId: str, toId: str):
    """İki öğrenci arasındaki en kısa bağlantı zinciri (shortestPath)."""
    record = await RecommendationService.find_shortest_connection(fromId, toId)
    if not record or not record["chain"]:
        raise HTTPException(
            status_code=404,
            detail="Bu iki öğrenci arasında 6 hop içinde bir bağlantı bulunamadı.",
        )
    return ConnectionPath(chain=record["chain"], hops=record["hops"])


@router.get("/stats/departments", response_model=list[DepartmentStat])
async def department_stats():
    """Bölüm bazında öğrenci ve ortalama arkadaş istatistikleri."""
    records = await RecommendationService.get_department_stats()
    return [DepartmentStat(**dict(r)) for r in records]