from app.db.neo4j_driver import get_session
from app.models.models import PostCreate
import uuid


class PostService:

    @staticmethod
    async def create_post(student_id: str, data: PostCreate):
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})
                CREATE (p:Post {
                    postId:     $postId,
                    content:    $content,
                    imageUrl:   $imageUrl,
                    likesCount: 0,
                    createdAt:  datetime()
                })
                CREATE (s)-[:POSTED]->(p)
                RETURN p, s.name AS authorName
                """,
                studentId=student_id,
                postId=str(uuid.uuid4()),
                content=data.content,
                imageUrl=data.imageUrl,
            )
            return await result.single()

    @staticmethod
    async def get_personalized_feed(student_id: str, limit: int):
        """
        Arkadaşların postlarını getir + beğenip beğenmediğimizi de döndür.
        Düzeltme: Friendship traversal yönü düzeltildi.
        """
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (me:Student {studentId: $studentId})
                      -[:SENT_BY|RECEIVED_BY]->(f:Friendship {status: 'accepted'})<-[:SENT_BY|RECEIVED_BY]-(friend:Student)
                MATCH (friend)-[:POSTED]->(p:Post)
                OPTIONAL MATCH (me)-[liked:LIKED]->(p)
                WITH p, friend, liked
                ORDER BY p.createdAt DESC
                LIMIT $limit
                RETURN p.postId     AS postId,
                       p.content    AS content,
                       p.imageUrl   AS imageUrl,
                       p.likesCount AS likesCount,
                       toString(p.createdAt) AS createdAt,
                       friend.name  AS authorName,
                       friend.studentId AS authorId,
                       liked IS NOT NULL AS isLiked
                """,
                studentId=student_id,
                limit=limit,
            )
            return [record async for record in result]

    @staticmethod
    async def get_my_posts(student_id: str):
        """Öğrencinin kendi postları, en yeniden eskiye."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})-[:POSTED]->(p:Post)
                RETURN p.postId     AS postId,
                       p.content    AS content,
                       p.imageUrl   AS imageUrl,
                       p.likesCount AS likesCount,
                       toString(p.createdAt) AS createdAt,
                       s.name       AS authorName,
                       s.studentId  AS authorId
                ORDER BY p.createdAt DESC
                """,
                studentId=student_id,
            )
            return [record async for record in result]

    @staticmethod
    async def like_post(student_id: str, post_id: str):
        """Beğeni ilişkisi kur ve sayacı artır (idempotent — MERGE)."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})
                MATCH (p:Post     {postId:     $postId})
                MERGE (s)-[l:LIKED]->(p)
                ON CREATE SET
                    l.likedAt    = datetime(),
                    p.likesCount = p.likesCount + 1
                RETURN p.likesCount AS total, (l.likedAt IS NOT NULL) AS isLiked
                """,
                studentId=student_id,
                postId=post_id,
            )
            return await result.single()

    @staticmethod
    async def unlike_post(student_id: str, post_id: str):
        """Beğeniyi geri al ve sayacı azalt."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})-[l:LIKED]->(p:Post {postId: $postId})
                DELETE l
                SET p.likesCount = CASE WHEN p.likesCount > 0 THEN p.likesCount - 1 ELSE 0 END
                RETURN p.likesCount AS total
                """,
                studentId=student_id,
                postId=post_id,
            )
            return await result.single()

    @staticmethod
    async def delete_post(student_id: str, post_id: str):
        """Postun sahibi silme isteği gönderdiyse sil."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})-[:POSTED]->(p:Post {postId: $postId})
                DETACH DELETE p
                RETURN $postId AS deletedId
                """,
                studentId=student_id,
                postId=post_id,
            )
            return await result.single()