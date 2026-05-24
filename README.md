# UniLink — Kampüs Sosyal Ağı / Campus Social Network

[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com)
[![Neo4j](https://img.shields.io/badge/Neo4j-008CC1?style=for-the-badge&logo=neo4j&logoColor=white)](https://neo4j.com)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

UniLink, **Neo4j Grafik Veritabanı** üzerine kurulu, kampüs içi etkileşimi ve sosyalleşmeyi artırmak amacıyla geliştirilmiş bir kampüs sosyal ağı uygulamasıdır. 
Bu depo (repository), hem **FastAPI** ile yazılmış backend API servislerini hem de **Flutter** ile geliştirilmiş mobil/web istemcisini barındırmaktadır. Projenin hem frontend hem de backend bileşenleri, ölçeklenebilirliği, test edilebilirliği ve bakımı kolaylaştırmak amacıyla **Clean Architecture (Temiz Mimari)** prensiplerine uygun olarak geliştirilmiştir.

*UniLink is a full-featured campus social network built on a **Neo4j Graph Database** to enhance campus interaction and socialization. This repository contains both the **FastAPI** backend API services and the **Flutter** mobile/web client. Both frontend and backend components are developed in compliance with **Clean Architecture** principles to ensure scalability, testability, and maintainability.*

---

## 📂 Proje Yapısı / Project Structure

```text
UniLink/
├── backend/                  # FastAPI Backend Servisi
│   ├── app/
│   │   ├── api/routes/       # API Uç Noktaları (Presentation/Controllers)
│   │   ├── db/               # Veritabanı Bağlantı Altyapısı (Infrastructure)
│   │   ├── models/           # Veri Modelleri (Domain/DTO)
│   │   ├── seed/             # Test Verisi Üretici (Mocking)
│   │   └── services/         # İş Mantığı & Sorgular (Application Services)
│   ├── .env                  # Çevre Değişkenleri
│   ├── requirements.txt      # Bağımlılıklar
│   └── .venv/                # Sanal Ortam
│
├── frontend/                 # Flutter Frontend Uygulaması
│   ├── lib/
│   │   ├── core/             # Paylaşılan Yapılandırmalar (Core Utility/Theme)
│   │   ├── data/             # Veri Katmanı (Data Sources, Repositories, Models)
│   │   ├── presentation/     # Sunum Katmanı (UI Screens, Widgets, Providers)
│   │   └── main.dart         # Uygulama Başlangıç Noktası
│   ├── pubspec.yaml          # Paket Tanımları
│   └── .gitignore            # Git Kuralları
│
└── .gitignore                # Global Git Kuralları
```

---

## [TR]
### 🌟 Temel Özellikler
*   **Öğrenci Profili & Arkadaşlık Sistemi:** Öğrencilerin birbirleriyle bağlantı kurmasını ve arkadaşlık ilişkilerini (gönderen, alan, onay durumu) grafik tabanlı yönetir.
*   **Kişiselleştirilmiş Akış (Post Feed):** Takip edilen veya arkadaş olunan kişilerin paylaşımlarının anlık görüntülenmesi ve beğenilmesi.
*   **Kulüpler & Etkinlikler:** Kampüs kulüplerine üyelik, etkinlik oluşturma, katılım sağlama ve kulüp bazlı etkinlik takibi.
*   **Grafik Tabanlı Öneriler:**
    *   **Arkadaş Önerisi:** Arkadaşınızın arkadaşı olan ancak sizin arkadaşınız olmayan kişilerin (ortak arkadaş sayısına göre) önerilmesi.
    *   **Etkinlik Önerisi:** İlgi duyduğunuz kulüplerin veya arkadaşlarınızın katıldığı etkinliklerin size önerilmesi.
*   **shortestPath (Bağlantı Zinciri):** Herhangi iki öğrenci arasındaki sosyal bağlantı zincirini en kısa yolla bulma.

### 🛠️ Backend Kurulumu
1.  **Backend dizinine geçiş yapın:**
    ```bash
    cd backend
    ```
2.  **Sanal ortam oluşturun ve aktif edin:**
    ```bash
    python -m venv .venv
    # Windows için aktif etme:
    .venv\Scripts\activate
    # macOS/Linux için aktif etme:
    source .venv/bin/activate
    ```
3.  **Gerekli bağımlılıkları yükleyin:**
    ```bash
    pip install -r requirements.txt
    ```
4.  **`.env` dosyasını yapılandırın:**
    `backend/.env` dosyası içerisine Neo4j veritabanı bilgilerinizi girin:
    ```env
    NEO4J_URI=neo4j+s://your-neo4j-uri.databases.neo4j.io
    NEO4J_USERNAME=neo4j
    NEO4J_PASSWORD=your-password
    ```
5.  **Veritabanını test verisi ile doldurun (Seeding):**
    ```bash
    python -m app.seed.generate
    ```
6.  **Backend sunucusunu başlatın:**
    ```bash
    uvicorn app.main:app --reload
    ```
    API belgelerine `http://127.0.0.1:8000/docs` adresinden Swagger UI ile erişebilirsiniz.

### 📱 Frontend Kurulumu
1.  **Frontend dizinine geçiş yapın:**
    ```bash
    cd ../frontend
    ```
2.  **Flutter paketlerini indirin:**
    ```bash
    flutter pub get
    ```
3.  **Uygulamayı çalıştırın:**
    ```bash
    flutter run
    ```

---

## [ENG]

### 🌟 Key Features
*   **Student Profile & Friendship System:** Manage friendship relations (sender, receiver, status) using Neo4j's graph structures.
*   **Personalized Post Feed:** Instantly view and like posts shared by friends or students you follow.
*   **Clubs & Events:** Club memberships, creating/organizing events, tracking event attendance.
*   **Graph-based Recommendations:**
    *   *Friend Recommendations:* Recommending people who are friends of your friends (ordered by number of mutual friends).
    *   *Event Recommendations:* Recommending campus events organized by your clubs or events that your friends are attending.
*   **shortestPath (Social Connection Chain):** Discover the shortest path of social connections between any two students.

### 🛠️ Backend Setup
1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```
2.  **Create and activate a virtual environment:**
    ```bash
    python -m venv .venv
    # For Windows:
    .venv\Scripts\activate
    # For macOS/Linux:
    source .venv/bin/activate
    ```
3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
4.  **Configure the `.env` file:**
    Enter your Neo4j database credentials inside `backend/.env`:
    ```env
    NEO4J_URI=neo4j+s://your-neo4j-uri.databases.neo4j.io
    NEO4J_USERNAME=neo4j
    NEO4J_PASSWORD=your-password
    ```
5.  **Seed the database with mock data:**
    ```bash
    python -m app.seed.generate
    ```
6.  **Run the backend server:**
    ```bash
    uvicorn app.main:app --reload
    ```
    Access interactive Swagger API documentation at `http://127.0.0.1:8000/docs`.

### 📱 Frontend Setup
1.  **Navigate to the frontend directory:**
    ```bash
    cd ../frontend
    ```
2.  **Fetch Flutter packages:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 📊 Veritabanı Grafik Şeması / Database Graph Schema

UniLink, ilişkisel veritabanları yerine verilerin birbirleriyle olan bağlantılarını en doğal şekilde saklamak için bir **Graph Database** olan Neo4j kullanır.

### Node (Düğüm) Tipleri
*   `Student` (Öğrenci): `studentId`, `name`, `department`, `year`, `email`, `createdAt`
*   `Post` (Gönderi): `postId`, `content`, `likesCount`, `createdAt`
*   `Club` (Kulüp): `clubId`, `name`, `category`
*   `Event` (Etkinlik): `eventId`, `title`, `date`, `venue`
*   `Friendship` (Arkadaşlık Arayüzü): `friendshipId`, `status`, `requestedBy`, `since`

### Relationship (İlişki) Tipleri
*   `(:Student)-[:POSTED]->(:Post)`
*   `(:Student)-[:LIKED]->(:Post)`
*   `(:Student)-[:MEMBER_OF]->(:Club)`
*   `(:Student)-[:ATTENDED]->(:Event)`
*   `(:Club)-[:ORGANIZED]->(:Event)`
*   `(:Student)-[:SENT_BY]->(:Friendship)`
*   `(:Student)-[:RECEIVED_BY]->(:Friendship)`

---

## 🔌 API Uç Noktaları / API Endpoints (FastAPI)

| Kategori | Metot | Uç Nokta (Endpoint) | Açıklama / Description |
| :--- | :---: | :--- | :--- |
| **Öğrenciler** | `POST` | `/students` | Yeni öğrenci kaydı / Register new student |
| | `GET` | `/students/{studentId}` | Öğrenci detayı / Get student profile |
| **Arkadaşlık** | `POST` | `/friendships/request` | Arkadaşlık isteği yolla / Send friend request |
| | `POST` | `/friendships/respond` | İsteği yanıtla (Kabul/Red) / Respond to request |
| | `GET` | `/students/{studentId}/friends` | Arkadaş listesi / Get list of friends |
| **Kulüp / Etkinlik** | `POST` | `/clubs` / `/events` | Kulüp / Etkinlik oluştur / Create club or event |
| | `POST` | `/clubs/join` | Kulübe katıl / Join a club |
| | `POST` | `/events/attend` | Etkinliğe katıl / Attend an event |
| **Öneriler (Graph)** | `GET` | `/recommendations/{studentId}/friends` | Arkadaş önerileri / Friend recommendations |
| | `GET` | `/recommendations/{studentId}/events` | Etkinlik önerileri / Event recommendations |
| | `GET` | `/recommendations/path` | İki öğrenci arası en kısa yol / shortestPath find |
