"""
UniLink — Kampüs sosyal ağı için sahte veri üretici.
Çalıştır: python -m app.seed.generate   (backend/ klasöründen)
         ya da: python seed/generate.py (app/ klasöründen)
Gereksinim: pip install faker neo4j python-dotenv
"""

from faker import Faker
from neo4j import GraphDatabase
import random
import uuid
import os
from dotenv import load_dotenv

load_dotenv()
fake = Faker("tr_TR")

URI      = os.getenv("NEO4J_URI")
USERNAME = os.getenv("NEO4J_USERNAME")
PASSWORD = os.getenv("NEO4J_PASSWORD")

DEPARTMENTS = [
    "Bilgisayar Müh.", "Elektrik-Elektronik Müh.", "Endüstri Müh.",
    "Makine Müh.", "İşletme", "Psikoloji", "Hukuk", "Tıp",
    "Mimarlık", "Matematik",
]

CLUBS = [
    {"clubId": "c1", "name": "Yazılım Kulübü",     "category": "Teknoloji"},
    {"clubId": "c2", "name": "Fotoğraf Kulübü",    "category": "Sanat"},
    {"clubId": "c3", "name": "Satranç Kulübü",      "category": "Oyun"},
    {"clubId": "c4", "name": "Müzik Kulübü",        "category": "Sanat"},
    {"clubId": "c5", "name": "Girişimcilik Kulübü", "category": "İş"},
    {"clubId": "c6", "name": "Spor Kulübü",         "category": "Spor"},
    {"clubId": "c7", "name": "Sinema Kulübü",       "category": "Sanat"},
    {"clubId": "c8", "name": "Doğa ve Çevre Kulübü","category": "Çevre"},
]

EVENTS = [
    {"eventId": "e1", "title": "Hackathon 2026",        "date": "2026-06-15", "venue": "A Blok",   "clubId": "c1"},
    {"eventId": "e2", "title": "Fotoğraf Sergisi",      "date": "2026-06-20", "venue": "Galeri",   "clubId": "c2"},
    {"eventId": "e3", "title": "Satranç Turnuvası",     "date": "2026-07-01", "venue": "B201",     "clubId": "c3"},
    {"eventId": "e4", "title": "Bahar Konseri",         "date": "2026-07-10", "venue": "Amfi",     "clubId": "c4"},
    {"eventId": "e5", "title": "Startup Weekend 2026",  "date": "2026-07-20", "venue": "C Blok",   "clubId": "c5"},
    {"eventId": "e6", "title": "Spor Şenliği",          "date": "2026-06-25", "venue": "Saha",     "clubId": "c6"},
    {"eventId": "e7", "title": "Kısa Film Festivali",   "date": "2026-08-05", "venue": "Sinema S.", "clubId": "c7"},
    {"eventId": "e8", "title": "Doğa Yürüyüşü",        "date": "2026-08-15", "venue": "Kampüs Dışı","clubId": "c8"},
]

POST_TEMPLATES = [
    "Bugün {} dersinde çok güzel bir şey öğrendim!",
    "Kampüste {} hakkında harika bir sunum vardı.",
    "Bu hafta {} kulübünde muhteşem bir etkinlik olacak.",
    "{} projesi için ekip arkadaşı arıyorum, ilgilenen var mı?",
    "Sınav döneminde {} kütüphanesi gerçekten iyi çalışma alanı.",
    "Bugün {} hakkında düşündüm ve şunu fark ettim:",
    "Kampüs kafeteryasında {} ile ilgili sohbet çok ilginçti.",
    "Mezuniyet sonrası {} alanında kariyer yapmayı düşünüyorum.",
]


def generate_students(n: int = 250):
    students = []
    for i in range(n):
        dept = random.choice(DEPARTMENTS)
        students.append({
            "studentId":  f"s{str(uuid.uuid4())[:7]}",
            "name":       fake.name(),
            "department": dept,
            "year":       random.randint(1, 4),
            "email":      fake.email(),
        })
    return students


def generate_posts(students, n_per_student: int = 3):
    topics = ["algoritma", "veri bilimi", "girişimcilik", "sürdürülebilirlik",
              "yapay zeka", "grafik tasarım", "blockchain", "siber güvenlik"]
    posts = []
    for s in students:
        for _ in range(random.randint(1, n_per_student)):
            template = random.choice(POST_TEMPLATES)
            posts.append({
                "postId":     str(uuid.uuid4()),
                "content":    template.format(random.choice(topics)),
                "imageUrl":   None,
                "likesCount": random.randint(0, 80),
                "studentId":  s["studentId"],
            })
    return posts


def generate_friendships(students, density: float = 0.06):
    ids = [s["studentId"] for s in students]
    friendships = []
    for i, a in enumerate(ids):
        for b in ids[i + 1:]:
            if random.random() < density:
                status = random.choice(["accepted", "accepted", "accepted", "pending"])
                friendships.append({
                    "friendshipId": str(uuid.uuid4()),
                    "status":       status,
                    "senderId":     a,
                    "receiverId":   b,
                })
    return friendships


def seed(driver, students, posts, friendships):
    with driver.session() as session:

        session.run("CREATE CONSTRAINT IF NOT EXISTS FOR (s:Student)    REQUIRE s.studentId    IS UNIQUE")
        session.run("CREATE CONSTRAINT IF NOT EXISTS FOR (p:Post)       REQUIRE p.postId       IS UNIQUE")
        session.run("CREATE CONSTRAINT IF NOT EXISTS FOR (c:Club)       REQUIRE c.clubId       IS UNIQUE")
        session.run("CREATE CONSTRAINT IF NOT EXISTS FOR (e:Event)      REQUIRE e.eventId      IS UNIQUE")
        session.run("CREATE CONSTRAINT IF NOT EXISTS FOR (f:Friendship) REQUIRE f.friendshipId IS UNIQUE")
        print("✅ Constraints OK")

        session.run(
            """
            UNWIND $students AS s
            MERGE (n:Student {studentId: s.studentId})
            SET n.name       = s.name,
                n.department = s.department,
                n.year       = s.year,
                n.email      = s.email,
                n.createdAt  = datetime()
            """,
            students=students,
        )
        print(f"✅ {len(students)} öğrenci eklendi.")

        session.run(
            "UNWIND $clubs AS c MERGE (n:Club {clubId: c.clubId}) SET n.name=c.name, n.category=c.category",
            clubs=CLUBS,
        )
        print("✅ Kulüpler eklendi.")

        session.run(
            """
            UNWIND $events AS e
            MERGE (ev:Event {eventId: e.eventId})
            SET ev.title = e.title, ev.date = date(e.date), ev.venue = e.venue
            WITH ev, e
            MATCH (c:Club {clubId: e.clubId})
            MERGE (c)-[:ORGANIZED]->(ev)
            """,
            events=EVENTS,
        )
        print("✅ Etkinlikler eklendi.")

        session.run(
            """
            UNWIND $posts AS p
            MATCH (s:Student {studentId: p.studentId})
            CREATE (post:Post {
                postId:     p.postId,
                content:    p.content,
                imageUrl:   p.imageUrl,
                likesCount: p.likesCount,
                createdAt:  datetime()
            })
            CREATE (s)-[:POSTED]->(post)
            """,
            posts=posts,
        )
        print(f"✅ {len(posts)} post eklendi.")

        session.run(
            """
            UNWIND $friendships AS f
            MATCH (a:Student {studentId: f.senderId})
            MATCH (b:Student {studentId: f.receiverId})
            CREATE (fr:Friendship {
                friendshipId: f.friendshipId,
                status:       f.status,
                requestedBy:  f.senderId,
                since:        datetime()
            })
            CREATE (a)-[:SENT_BY]->(fr)
            CREATE (b)-[:RECEIVED_BY]->(fr)
            """,
            friendships=friendships,
        )
        print(f"✅ {len(friendships)} arkadaşlık oluşturuldu.")

        student_ids = [s["studentId"] for s in students]
        club_ids    = [c["clubId"] for c in CLUBS]
        memberships = []
        for sid in student_ids:
            for cid in random.sample(club_ids, k=random.randint(1, 3)):
                memberships.append({"studentId": sid, "clubId": cid})
        session.run(
            """
            UNWIND $memberships AS m
            MATCH (s:Student {studentId: m.studentId})
            MATCH (c:Club    {clubId:    m.clubId})
            MERGE (s)-[:MEMBER_OF]->(c)
            """,
            memberships=memberships,
        )
        print(f"✅ {len(memberships)} kulüp üyeliği eklendi.")

        event_ids   = [e["eventId"] for e in EVENTS]
        attendances = []
        for sid in student_ids:
            for eid in random.sample(event_ids, k=random.randint(0, 4)):
                attendances.append({"studentId": sid, "eventId": eid})
        session.run(
            """
            UNWIND $attendances AS a
            MATCH (s:Student {studentId: a.studentId})
            MATCH (e:Event   {eventId:   a.eventId})
            MERGE (s)-[:ATTENDED]->(e)
            """,
            attendances=attendances,
        )
        print(f"✅ {len(attendances)} etkinlik katılımı eklendi.")

        post_ids = [p["postId"] for p in posts]
        likes = []
        for sid in random.sample(student_ids, k=min(100, len(student_ids))):
            for pid in random.sample(post_ids, k=random.randint(2, 10)):
                likes.append({"studentId": sid, "postId": pid})
        session.run(
            """
            UNWIND $likes AS l
            MATCH (s:Student {studentId: l.studentId})
            MATCH (p:Post    {postId:    l.postId})
            MERGE (s)-[:LIKED]->(p)
            """,
            likes=likes,
        )
        print(f"✅ {len(likes)} beğeni eklendi.")

        print("\n📊 Seed tamamlandı! Node sayıları:")
        counts = session.run(
            """
            MATCH (n) WITH labels(n)[0] AS lbl, COUNT(n) AS cnt
            RETURN lbl, cnt ORDER BY cnt DESC
            """
        )
        for row in counts:
            print(f"   {row['lbl']}: {row['cnt']}")

        print("\n📊 Relationship sayıları:")
        rel_counts = session.run(
            """
            MATCH ()-[r]->() WITH type(r) AS rel, COUNT(r) AS cnt
            RETURN rel, cnt ORDER BY cnt DESC
            """
        )
        for row in rel_counts:
            print(f"   {row['rel']}: {row['cnt']}")


if __name__ == "__main__":
    driver = GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))
    print("🚀 Seed başlatılıyor...")
    students    = generate_students(250)
    posts       = generate_posts(students, n_per_student=3)
    friendships = generate_friendships(students, density=0.06)
    seed(driver, students, posts, friendships)
    driver.close()
    print("\n✨ Tamamlandı!")
