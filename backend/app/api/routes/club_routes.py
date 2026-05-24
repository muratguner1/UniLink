from fastapi import APIRouter, HTTPException, Query
from app.models.models import ClubOut, ClubDetailOut
from app.services.club_service import ClubService

router = APIRouter(prefix="/clubs", tags=["clubs"])


@router.get("/", response_model=list[ClubOut])
async def get_all_clubs(
    studentId: str | None = Query(default=None, description="Üyelik durumunu görmek için studentId"),
):
    """Tüm kulüpler. studentId verilirse isMember alanı doldurulur."""
    records = await ClubService.get_all_clubs(studentId)
    return [ClubOut(**dict(r)) for r in records]


@router.get("/{clubId}", response_model=ClubDetailOut)
async def get_club_detail(clubId: str):
    """Kulüp detayı + etkinlikleri."""
    record = await ClubService.get_club_detail(clubId)
    if not record:
        raise HTTPException(status_code=404, detail="Kulüp bulunamadı.")
    return ClubDetailOut(**dict(record))


@router.get("/{clubId}/students", tags=["clubs"])
async def get_student_clubs(studentId: str = Query(...)):
    """Öğrencinin üye olduğu kulüpler."""
    records = await ClubService.get_student_clubs(studentId)
    return [ClubOut(**dict(r)) for r in records]


@router.post("/{clubId}/join")
async def join_club(
    clubId: str,
    studentId: str = Query(..., description="Katılacak öğrencinin ID'si"),
):
    """Kulübe katıl."""
    record = await ClubService.join_club(studentId, clubId)
    if not record:
        raise HTTPException(status_code=404, detail="Kulüp veya öğrenci bulunamadı.")
    return {"clubId": clubId, "memberCount": record["memberCount"], "isMember": True}


@router.delete("/{clubId}/leave")
async def leave_club(
    clubId: str,
    studentId: str = Query(..., description="Ayrılacak öğrencinin ID'si"),
):
    """Kulüpten ayrıl."""
    record = await ClubService.leave_club(studentId, clubId)
    if not record:
        raise HTTPException(status_code=404, detail="Üyelik bulunamadı.")
    return {"clubId": clubId, "isMember": False}
