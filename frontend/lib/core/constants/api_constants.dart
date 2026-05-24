// ─────────────────────────────────────────────────────────────────────────────
// API Base URL Konfigürasyonu
//
// Android Emülatör: http://10.0.2.2:8000
// Fiziksel Cihaz  : http://<bilgisayarının_IP'si>:8000
//   (Wi-Fi ayarlarında veya `ipconfig` ile öğren)
// ─────────────────────────────────────────────────────────────────────────────

class ApiConstants {
  // Android emülatörden host makinaya erişim için özel IP
  static const String baseUrl = 'http://172.20.10.3:8000';

  // ── Students ──────────────────────────────────────────────────────────────
  static const String login = '/students/login';
  static const String students = '/students/';
  static String studentById(String id) => '/students/$id';
  static String searchStudents(String q) => '/students/search?q=$q';
  static String friends(String id) => '/students/$id/friends';
  static String friendRequest(String id) => '/students/$id/friend-request';
  static String pendingRequests(String id) => '/students/$id/friend-requests';
  static String acceptFriendship(String fid) =>
      '/students/friendships/$fid/accept';
  static String declineFriendship(String fid) =>
      '/students/friendships/$fid/decline';

  // ── Feed ──────────────────────────────────────────────────────────────────
  static String feed(String id, {int limit = 30}) => '/feed/$id?limit=$limit';
  static String myPosts(String id) => '/feed/$id/my-posts';
  static String createPost(String id) => '/feed/$id/posts';
  static String likePost(String uid, String pid) =>
      '/feed/$uid/posts/$pid/like';
  static String unlikePost(String uid, String pid) =>
      '/feed/$uid/posts/$pid/like';
  static String deletePost(String uid, String pid) => '/feed/$uid/posts/$pid';

  // ── Clubs ─────────────────────────────────────────────────────────────────
  static String clubs({String? studentId}) =>
      studentId != null ? '/clubs/?studentId=$studentId' : '/clubs/';
  static String clubDetail(String id) => '/clubs/$id';
  static String joinClub(String id, String sid) =>
      '/clubs/$id/join?studentId=$sid';
  static String leaveClub(String id, String sid) =>
      '/clubs/$id/leave?studentId=$sid';

  // ── Events ────────────────────────────────────────────────────────────────
  static String events({String? studentId}) =>
      studentId != null ? '/events/?studentId=$studentId' : '/events/';
  static String attendEvent(String eid, String sid) =>
      '/events/$eid/attend?studentId=$sid';
  static String leaveEvent(String eid, String sid) =>
      '/events/$eid/leave?studentId=$sid';

  // ── Recommendations ───────────────────────────────────────────────────────
  static String recommendFriends(String id, {int limit = 10}) =>
      '/recommendations/$id/friends?limit=$limit';
  static String recommendEvents(String id) => '/recommendations/$id/events';
  static String connectionPath(String a, String b) =>
      '/recommendations/path/$a/$b';
  static const String deptStats = '/recommendations/stats/departments';
}
