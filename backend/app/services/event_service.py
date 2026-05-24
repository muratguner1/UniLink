from app.db.neo4j_driver import get_session


class EventService:

    @staticmethod
    async def get_all_events(student_id: str | None = None):
        """
        Tüm etkinlikler, yaklaşan sıralı.
        student_id verilirse katılıp katılmadığını da döndür.
        """
        async with get_session() as session:
            if student_id:
                result = await session.run(
                    """
                    MATCH (c:Club)-[:ORGANIZED]->(e:Event)
                    OPTIONAL MATCH (s:Student {studentId: $studentId})-[att:ATTENDED]->(e)
                    WITH e, c,
                         COUNT { MATCH (e)<-[:ATTENDED]-(:Student) } AS attendeeCount,
                         att IS NOT NULL AS isAttending
                    RETURN e.eventId  AS eventId,
                           e.title    AS title,
                           toString(e.date) AS date,
                           e.venue    AS venue,
                           c.name     AS organizer,
                           c.clubId   AS clubId,
                           attendeeCount,
                           isAttending
                    ORDER BY e.date ASC
                    """,
                    studentId=student_id,
                )
            else:
                result = await session.run(
                    """
                    MATCH (c:Club)-[:ORGANIZED]->(e:Event)
                    WITH e, c,
                         COUNT { MATCH (e)<-[:ATTENDED]-(:Student) } AS attendeeCount
                    RETURN e.eventId  AS eventId,
                           e.title    AS title,
                           toString(e.date) AS date,
                           e.venue    AS venue,
                           c.name     AS organizer,
                           c.clubId   AS clubId,
                           attendeeCount,
                           false AS isAttending
                    ORDER BY e.date ASC
                    """
                )
            return [record async for record in result]

    @staticmethod
    async def attend_event(student_id: str, event_id: str):
        """Etkinliğe katıl (ATTENDED ilişkisi oluştur)."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})
                MATCH (e:Event {eventId: $eventId})
                MERGE (s)-[a:ATTENDED]->(e)
                ON CREATE SET a.attendedAt = datetime()
                WITH e,
                     COUNT { MATCH (e)<-[:ATTENDED]-(:Student) } AS attendeeCount
                RETURN e.eventId AS eventId, attendeeCount
                """,
                studentId=student_id,
                eventId=event_id,
            )
            return await result.single()

    @staticmethod
    async def leave_event(student_id: str, event_id: str):
        """Etkinlik katılımını iptal et."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student {studentId: $studentId})-[a:ATTENDED]->(e:Event {eventId: $eventId})
                DELETE a
                RETURN e.eventId AS eventId
                """,
                studentId=student_id,
                eventId=event_id,
            )
            return await result.single()

    @staticmethod
    async def get_event_attendees(event_id: str):
        """Etkinliğe katılan öğrenciler."""
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student)-[:ATTENDED]->(e:Event {eventId: $eventId})
                RETURN s.studentId  AS studentId,
                       s.name       AS name,
                       s.department AS department
                ORDER BY s.name
                """,
                eventId=event_id,
            )
            return [record async for record in result]
