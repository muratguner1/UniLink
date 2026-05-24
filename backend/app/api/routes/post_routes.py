from fastapi import APIRouter, HTTPException, Query
from app.models.models import PostCreate, PostOut
from app.services.post_service import PostService

router = APIRouter(prefix="/feed", tags=["feed"])


@router.post("/{studentId}/posts", response_model=PostOut, status_code=201)
async def create_post(studentId: str, data: PostCreate):
    """Yeni post oluştur."""
    record = await PostService.create_post(studentId, data)
    if not record:
        raise HTTPException(status_code=404, detail="Öğrenci bulunamadı.")
    p = record["p"]
    return PostOut(
        postId=p["postId"],
        content=p["content"],
        imageUrl=p.get("imageUrl"),
        likesCount=p["likesCount"],
        createdAt=str(p["createdAt"]),
        authorName=record["authorName"],
        authorId=studentId,
        isLiked=False,
    )


@router.get("/{studentId}", response_model=list[PostOut])
async def get_feed(
    studentId: str,
    limit: int = Query(default=20, ge=1, le=100),
):
    """Kişiselleştirilmiş feed: arkadaşların postları."""
    records = await PostService.get_personalized_feed(studentId, limit)
    return [PostOut(**dict(r)) for r in records]


@router.get("/{studentId}/my-posts", response_model=list[PostOut])
async def get_my_posts(studentId: str):
    """Öğrencinin kendi postları."""
    records = await PostService.get_my_posts(studentId)
    return [PostOut(**dict(r)) for r in records]


@router.post("/{studentId}/posts/{postId}/like")
async def like_post(studentId: str, postId: str):
    """Post beğen."""
    record = await PostService.like_post(studentId, postId)
    if not record:
        raise HTTPException(status_code=404, detail="Post veya öğrenci bulunamadı.")
    return {"postId": postId, "likesCount": record["total"], "isLiked": True}


@router.delete("/{studentId}/posts/{postId}/like")
async def unlike_post(studentId: str, postId: str):
    """Beğeniyi geri al."""
    record = await PostService.unlike_post(studentId, postId)
    if not record:
        raise HTTPException(status_code=404, detail="Beğeni bulunamadı.")
    return {"postId": postId, "likesCount": record["total"], "isLiked": False}


@router.delete("/{studentId}/posts/{postId}", status_code=204)
async def delete_post(studentId: str, postId: str):
    """Post sil (sadece sahibi silebilir)."""
    record = await PostService.delete_post(studentId, postId)
    if not record:
        raise HTTPException(status_code=404, detail="Post bulunamadı veya yetkiniz yok.")