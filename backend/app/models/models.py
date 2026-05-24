from pydantic import BaseModel
from typing import Optional


# ── Student

class StudentOut(BaseModel):
    studentId: str
    name: str
    department: str
    year: int

class StudentCreate(BaseModel):
    studentId: str
    name: str
    department: str
    year: int
    email: str

class LoginRequest(BaseModel):
    studentId: str
    email: str

class LoginOut(BaseModel):
    """Login başarılı olduğunda dönen model."""
    studentId: str
    name: str
    department: str
    year: int


# ── Post

class PostOut(BaseModel):
    postId: str
    content: str
    imageUrl: Optional[str] = None
    likesCount: int
    createdAt: str
    authorName: str
    authorId: Optional[str] = None
    isLiked: Optional[bool] = False

class PostCreate(BaseModel):
    content: str
    imageUrl: Optional[str] = None


# ── Friendship

class FriendshipRequest(BaseModel):
    toStudentId: str

class FriendOut(BaseModel):
    studentId: str
    name: str
    department: str
    mutualFriends: int

class PendingRequestOut(BaseModel):
    """Gelen bekleyen arkadaşlık isteği."""
    studentId: str
    name: str
    department: str
    friendshipId: str
    since: str


# ── Recommendation

class RecommendationOut(BaseModel):
    studentId: str
    name: str
    department: str
    mutualFriends: int
    commonClubs: int
    score: int


# ── Club

class ClubOut(BaseModel):
    clubId: str
    name: str
    category: str
    memberCount: int
    isMember: Optional[bool] = False

class ClubDetailOut(BaseModel):
    clubId: str
    name: str
    category: str
    memberCount: int
    events: list[dict] = []

class ClubCreate(BaseModel):
    name: str
    category: str
    description: str


# ── Event

class EventOut(BaseModel):
    eventId: str
    title: str
    date: str
    venue: str
    organizer: str
    clubId: Optional[str] = None
    attendeeCount: int
    isAttending: Optional[bool] = False

class AttendeeOut(BaseModel):
    """Etkinliğe katılan öğrenci."""
    studentId: str
    name: str
    department: str


# ── Path / connection

class ConnectionPath(BaseModel):
    chain: list[str]
    hops: int


# ── Stats

class DepartmentStat(BaseModel):
    department: str
    studentCount: int
    avgFriends: float
