from fastapi import APIRouter, HTTPException, Query
from app.models.models import (
    StudentCreate, StudentOut, FriendOut,
    FriendshipRequest, PendingRequestOut, LoginRequest, LoginOut,
)
from app.services.student_service import StudentService

router = APIRouter(prefix="/students", tags=["students"])


@router.post("/login", response_model=LoginOut)
async def login(body: LoginRequest):
    """Basit giriş: studentId + email eşleşmesi."""
    record = await StudentService.login(body.studentId, body.email)
    if not record:
        raise HTTPException(status_code=401, detail="Geçersiz kimlik bilgileri.")
    s = record["s"]
    return LoginOut(**dict(s))


@router.post("/", response_model=StudentOut, status_code=201)
async def create_student(data: StudentCreate):
    record = await StudentService.create_student(data)
    if not record:
        raise HTTPException(status_code=400, detail="Öğrenci oluşturulamadı.")
    s = record["s"]
    return StudentOut(**dict(s))


@router.get("/search", response_model=list[StudentOut])
async def search_students(
    q: str = Query(..., min_length=1, description="Ada veya bölüme göre arama"),
    limit: int = Query(default=20, ge=1, le=50),
):
    """Öğrenci arama endpoint'i."""
    records = await StudentService.search_students(q, limit)
    return [StudentOut(**dict(r["s"])) for r in records]


@router.get("/{studentId}", response_model=StudentOut)
async def get_student(studentId: str):
    record = await StudentService.get_student_by_id(studentId)
    if not record:
        raise HTTPException(status_code=404, detail="Öğrenci bulunamadı.")
    return StudentOut(**dict(record["s"]))


@router.get("/{studentId}/friends", response_model=list[FriendOut])
async def get_friends(studentId: str):
    records = await StudentService.get_friends_with_mutuals(studentId)
    return [FriendOut(**dict(r)) for r in records]


@router.post("/{studentId}/friend-request", status_code=201)
async def send_friend_request(studentId: str, body: FriendshipRequest):
    if studentId == body.toStudentId:
        raise HTTPException(status_code=400, detail="Kendine istek gönderemezsin.")
    record = await StudentService.create_friend_request(studentId, body.toStudentId)
    if not record:
        raise HTTPException(status_code=404, detail="Öğrenci bulunamadı veya işlem başarısız.")
    return {"friendshipId": record["fid"], "status": "pending"}


@router.get("/{studentId}/friend-requests", response_model=list[PendingRequestOut])
async def get_pending_requests(studentId: str):
    """Gelen bekleyen arkadaşlık istekleri."""
    records = await StudentService.get_pending_requests(studentId)
    return [PendingRequestOut(**dict(r)) for r in records]


@router.patch("/friendships/{friendshipId}/accept")
async def accept_friendship(friendshipId: str):
    record = await StudentService.accept_friendship(friendshipId)
    if not record:
        raise HTTPException(status_code=404, detail="Bekleyen istek bulunamadı.")
    return {"friendshipId": friendshipId, "status": "accepted"}


@router.delete("/friendships/{friendshipId}/decline")
async def decline_friendship(friendshipId: str):
    record = await StudentService.decline_friendship(friendshipId)
    if not record:
        raise HTTPException(status_code=404, detail="Bekleyen istek bulunamadı.")
    return {"friendshipId": friendshipId, "status": "declined"}