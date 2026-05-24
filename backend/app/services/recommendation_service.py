from app.db.neo4j_driver import get_session


class RecommendationService:

    @staticmethod
    async def get_friend_recommendations(student_id: str, limit: int):
        """
        Hibrit öneri: arkadaşların arkadaşları + ortak kulüpler.
        Düzeltme: Friendship traversal yönleri (-[:REL]->node<-[:REL]-) düzeltildi.
        """
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (me:Student {studentId: $studentId})
                      -[:SENT_BY|RECEIVED_BY]->(f1:Friendship {status:'accepted'})<-[:SENT_BY|RECEIVED_BY]-(friend:Student)
                      -[:SENT_BY|RECEIVED_BY]->(f2:Friendship {status:'accepted'})<-[:SENT_BY|RECEIVED_BY]-(candidate:Student)
                WHERE candidate.studentId <> $studentId
                  AND NOT (me)-[:SENT_BY|RECEIVED_BY]->(:Friendship)<-[:SENT_BY|RECEIVED_BY]-(candidate)
                WITH me, candidate, COUNT(DISTINCT friend) AS mutualFriends

                OPTIONAL MATCH (me)-[:MEMBER_OF]->(c:Club)<-[:MEMBER_OF]-(candidate)
                WITH candidate, mutualFriends, COUNT(DISTINCT c) AS commonClubs

                WITH candidate,
                     mutualFriends,
                     commonClubs,
                     (mutualFriends * 2 + commonClubs * 3) AS score
                WHERE score > 0
                ORDER BY score DESC
                LIMIT $limit

                RETURN candidate.studentId  AS studentId,
                       candidate.name       AS name,
                       candidate.department AS department,
                       mutualFriends,
                       commonClubs,
                       score
                """,
                studentId=student_id,
                limit=limit,
            )
            return [record async for record in result]

    @staticmethod
    async def get_event_recommendations(student_id: str):
        """
        Üye olunan kulüplerin yaklaşan etkinlikleri.
        Düzeltme: e.date > date() filtresi çalışır hale getirildi.
        """
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (me:Student {studentId: $studentId})
                      -[:MEMBER_OF]->(c:Club)-[:ORGANIZED]->(e:Event)
                WHERE e.date >= date()
                  AND NOT (me)-[:ATTENDED]->(e)
                WITH e, c,
                     COUNT { MATCH (e)<-[:ATTENDED]-(:Student) } AS attendeeCount
                ORDER BY e.date ASC
                LIMIT 10
                RETURN e.eventId  AS eventId,
                       e.title    AS title,
                       toString(e.date) AS date,
                       e.venue    AS venue,
                       c.name     AS organizer,
                       c.clubId   AS clubId,
                       attendeeCount
                """,
                studentId=student_id,
            )
            return [record async for record in result]

    @staticmethod
    async def find_shortest_connection(from_id: str, to_id: str):
        """
        İki öğrenci arasındaki en kısa arkadaşlık zinciri.
        Friendship ara-node pattern: Student -> Friendship <- Student
        """
        async with get_session() as session:
            result = await session.run(
                """
                MATCH p = shortestPath(
                  (a:Student {studentId: $fromId})
                  -[:SENT_BY|RECEIVED_BY*..12]-
                  (b:Student {studentId: $toId})
                )
                RETURN [n IN nodes(p) WHERE n:Student | n.name] AS chain,
                       length(p) / 2 AS hops
                """,
                fromId=from_id,
                toId=to_id,
            )
            return await result.single()

    @staticmethod
    async def get_department_stats():
        """
        Bölüm bazında öğrenci dağılımı ve ortalama arkadaş sayısı.
        Aggregation + WITH pipeline örneği.
        """
        async with get_session() as session:
            result = await session.run(
                """
                MATCH (s:Student)
                OPTIONAL MATCH (s)-[:SENT_BY|RECEIVED_BY]->(:Friendship {status:'accepted'})
                WITH s.department AS department,
                     COUNT(DISTINCT s) AS studentCount,
                     COUNT(*) AS friendshipCount
                RETURN department,
                       studentCount,
                       round(toFloat(friendshipCount) / studentCount, 1) AS avgFriends
                ORDER BY studentCount DESC
                """
            )
            return [record async for record in result]