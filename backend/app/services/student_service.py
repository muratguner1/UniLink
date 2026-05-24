from app.db.neo4j_driver import get_session
from app.models.models import StudentCreate
import uuid


class StudentService:

    @staticmethod
    async def create_student(data: StudentCreate):
        async with get_session() as session:
            result = await session.run(
                """
                MERGE (s:Student {studentId: $studentId})
                ON CREATE SET
                    s.name       = $name,
                    s.department = $department,
                    s.year       = $year,
                    s.email      = $email,
                    s.createdAt  = datetime()
                RETURN s
                """,
                studentId=data.studentId,
                name=data.name,
                department=data.department,
                year=data.year,
                email=data.email,
            )
            return await result.single()

    @staticmethod
    async def get_student_by_id(student_id: str):
        async with get_session() as session:
            result = await session.run(
                "MATCH (s:Student {studentId: $studentId}) RETURN s",
                studentId=student_id,
            )
            return await result.single()

    @staticmethod
    async def search_students(query: str, limit: int = 20):
        """Ada veya bölüme göre öğrenci arama — CONTAINS ile case-insensitive."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student)
                WHERE toLower(s.name)       CONTAINS toLower($search_term)
                   OR toLower(s.department) CONTAINS toLower($search_term)
                RETURN s
                ORDER BY s.name
                LIMIT $limit
                """,
                search_term=query,
                limit=limit,
            )
            return [record async for record in result]

    @staticmethod
    async def get_friends_with_mutuals(student_id: str):
        """
        Arkadaş listesi + kaç ortak arkadaşları var.
        Düzeltme: relationship yönleri (-[:REL]->node<-[:REL]-) şeklinde.
        """
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (me:Student {studentId: $studentId})
                      -[:SENT_BY|RECEIVED_BY]->(f:Friendship {status: 'accepted'})<-[:SENT_BY|RECEIVED_BY]-(friend:Student)
                WHERE friend.studentId <> $studentId
                WITH me, friend
                OPTIONAL MATCH (me)-[:SENT_BY|RECEIVED_BY]->(mf:Friendship {status:'accepted'})<-[:SENT_BY|RECEIVED_BY]-(mutual:Student)
                              -[:SENT_BY|RECEIVED_BY]->(ff:Friendship {status:'accepted'})<-[:SENT_BY|RECEIVED_BY]-(friend)
                RETURN friend.studentId   AS studentId,
                       friend.name        AS name,
                       friend.department  AS department,
                       COUNT(DISTINCT mutual) AS mutualFriends
                ORDER BY mutualFriends DESC
                """,
                studentId=student_id,
            )
            return [record async for record in result]

    @staticmethod
    async def create_friend_request(sender_id: str, receiver_id: str):
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (sender:Student {studentId: $senderId})
                MATCH (receiver:Student {studentId: $receiverId})
                MERGE (f:Friendship {friendshipId: $friendshipId})
                ON CREATE SET
                    f.status      = 'pending',
                    f.since       = datetime(),
                    f.requestedBy = $senderId
                MERGE (sender)-[:SENT_BY]->(f)
                MERGE (receiver)-[:RECEIVED_BY]->(f)
                RETURN f.friendshipId AS fid
                """,
                senderId=sender_id,
                receiverId=receiver_id,
                friendshipId=str(uuid.uuid4()),
            )
            return await result.single()

    @staticmethod
    async def accept_friendship(friendship_id: str):
        """Arkadaşlık isteğini kabul et."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (f:Friendship {friendshipId: $friendshipId, status: 'pending'})
                SET f.status = 'accepted', f.acceptedAt = datetime()
                RETURN f.friendshipId AS fid
                """,
                friendshipId=friendship_id,   # ← BUG DÜZELTMESİ: eski hali friendship_id=friendship_id idi
            )
            return await result.single()

    @staticmethod
    async def decline_friendship(friendship_id: str):
        """Arkadaşlık isteğini reddet (node'u sil)."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (f:Friendship {friendshipId: $friendshipId, status: 'pending'})
                DETACH DELETE f
                RETURN $friendshipId AS fid
                """,
                friendshipId=friendship_id,
            )
            return await result.single()

    @staticmethod
    async def get_pending_requests(student_id: str):
        """Öğrenciye gelen bekleyen arkadaşlık istekleri."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (sender:Student)-[:SENT_BY]->(f:Friendship {status: 'pending'})<-[:RECEIVED_BY]-(me:Student {studentId: $studentId})
                RETURN sender.studentId AS studentId,
                       sender.name      AS name,
                       sender.department AS department,
                       f.friendshipId   AS friendshipId,
                       toString(f.since) AS since
                ORDER BY f.since DESC
                """,
                studentId=student_id,
            )
            return [record async for record in result]

    @staticmethod
    async def login(student_id: str, email: str):
        """Basit doğrulama: studentId + email eşleşirse öğrenciyi döndür."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId, email: $email})
                RETURN s
                """,
                studentId=student_id,
                email=email,
            )
            return await result.single()