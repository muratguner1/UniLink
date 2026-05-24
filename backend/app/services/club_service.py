from app.db.neo4j_driver import get_session


class ClubService:

    @staticmethod
    async def get_all_clubs(student_id: str | None = None):
        """
        Tüm kulüpleri getir.
        student_id verilirse, öğrencinin üye olup olmadığını da döndür.
        """
        async with get_session() as session:
            if student_id:
                result = await session.run(
                    """
                    MATCH (c:Club)
                    OPTIONAL MATCH (c)<-[m:MEMBER_OF]-(s:Student {studentId: $studentId})
                    WITH c,
                         COUNT { MATCH (c)<-[:MEMBER_OF]-(:Student) } AS memberCount,
                         m IS NOT NULL AS isMember
                    RETURN c.clubId    AS clubId,
                           c.name     AS name,
                           c.category AS category,
                           memberCount,
                           isMember
                    ORDER BY c.name
                    """,
                    studentId=student_id,
                )
            else:
                result = await session.run(
                    """
                    MATCH (c:Club)
                    WITH c,
                         COUNT { MATCH (c)<-[:MEMBER_OF]-(:Student) } AS memberCount
                    RETURN c.clubId    AS clubId,
                           c.name     AS name,
                           c.category AS category,
                           memberCount,
                           false AS isMember
                    ORDER BY c.name
                    """
                )
            return [record async for record in result]

    @staticmethod
    async def get_club_detail(club_id: str):
        """Kulüp detayı + üye sayısı + son etkinlikler."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (c:Club {clubId: $clubId})
                WITH c,
                     COUNT { MATCH (c)<-[:MEMBER_OF]-(:Student) } AS memberCount
                OPTIONAL MATCH (c)-[:ORGANIZED]->(e:Event)
                WITH c, memberCount, collect({
                    eventId: e.eventId,
                    title:   e.title,
                    date:    toString(e.date),
                    venue:   e.venue
                }) AS events
                RETURN c.clubId    AS clubId,
                       c.name     AS name,
                       c.category AS category,
                       memberCount,
                       events
                """,
                clubId=club_id,
            )
            return await result.single()

    @staticmethod
    async def get_student_clubs(student_id: str):
        """Bir öğrencinin üye olduğu kulüpler."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})-[:MEMBER_OF]->(c:Club)
                WITH c,
                     COUNT { MATCH (c)<-[:MEMBER_OF]-(:Student) } AS memberCount
                RETURN c.clubId    AS clubId,
                       c.name     AS name,
                       c.category AS category,
                       memberCount,
                       true AS isMember
                ORDER BY c.name
                """,
                studentId=student_id,
            )
            return [record async for record in result]

    @staticmethod
    async def join_club(student_id: str, club_id: str):
        """Kulübe katıl (MEMBER_OF ilişkisi oluştur)."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})
                MATCH (c:Club {clubId: $clubId})
                MERGE (s)-[m:MEMBER_OF]->(c)
                ON CREATE SET m.joinedAt = datetime()
                WITH c,
                     COUNT { MATCH (c)<-[:MEMBER_OF]-(:Student) } AS memberCount
                RETURN c.clubId AS clubId, memberCount
                """,
                studentId=student_id,
                clubId=club_id,
            )
            return await result.single()

    @staticmethod
    async def leave_club(student_id: str, club_id: str):
        """Kulüpten ayrıl (MEMBER_OF ilişkisini sil)."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})-[m:MEMBER_OF]->(c:Club {clubId: $clubId})
                DELETE m
                RETURN c.clubId AS clubId
                """,
                studentId=student_id,
                clubId=club_id,
            )
            return await result.single()
