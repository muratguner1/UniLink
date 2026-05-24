from fastapi import APIRouter, HTTPException, Query
from app.models.models import EventOut, AttendeeOut
from app.services.event_service import EventService

router = APIRouter(prefix="/events", tags=["events"])


@router.get("/", response_model=list[EventOut])
async def get_all_events(
    studentId: str | None = Query(default=None, description="Katılım durumunu görmek için studentId"),
):
    """Tüm etkinlikler, tarihe göre sıralı. studentId ile isAttending de döner."""
    records = await EventService.get_all_events(studentId)
    return [EventOut(**dict(r)) for r in records]


@router.get("/{eventId}/attendees", response_model=list[AttendeeOut])
async def get_event_attendees(eventId: str):
    """Etkinliğe katılan öğrenciler."""
    records = await EventService.get_event_attendees(eventId)
    return [AttendeeOut(**dict(r)) for r in records]


@router.post("/{eventId}/attend")
async def attend_event(
    eventId: str,
    studentId: str = Query(..., description="Katılacak öğrencinin ID'si"),
):
    """Etkinliğe katıl."""
    record = await EventService.attend_event(studentId, eventId)
    if not record:
        raise HTTPException(status_code=404, detail="Etkinlik veya öğrenci bulunamadı.")
    return {"eventId": eventId, "attendeeCount": record["attendeeCount"], "isAttending": True}


@router.delete("/{eventId}/leave")
async def leave_event(
    eventId: str,
    studentId: str = Query(..., description="Ayrılacak öğrencinin ID'si"),
):
    """Etkinlik katılımını iptal et."""
    record = await EventService.leave_event(studentId, eventId)
    if not record:
        raise HTTPException(status_code=404, detail="Katılım bulunamadı.")
    return {"eventId": eventId, "isAttending": False}
