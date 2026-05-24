import '../models/student_model.dart';
import '../models/recommendation_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class StudentRepository {
  final _api = ApiService();

  Future<StudentModel> login(String studentId, String email) async {
    final data = await _api.post(ApiConstants.login, body: {
      'studentId': studentId,
      'email': email,
    });
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  Future<StudentModel> register({
    required String studentId,
    required String name,
    required String department,
    required int year,
    required String email,
  }) async {
    final data = await _api.post(ApiConstants.students, body: {
      'studentId': studentId,
      'name': name,
      'department': department,
      'year': year,
      'email': email,
    });
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  Future<StudentModel> getById(String id) async {
    final data = await _api.get(ApiConstants.studentById(id));
    return StudentModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<StudentModel>> search(String query) async {
    final data = await _api.get(ApiConstants.searchStudents(Uri.encodeQueryComponent(query)));
    return (data as List).map((e) => StudentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FriendModel>> getFriends(String studentId) async {
    final data = await _api.get(ApiConstants.friends(studentId));
    return (data as List).map((e) => FriendModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendFriendRequest(String fromId, String toId) async {
    await _api.post(ApiConstants.friendRequest(fromId), body: {'toStudentId': toId});
  }

  Future<List<PendingRequestModel>> getPendingRequests(String studentId) async {
    final data = await _api.get(ApiConstants.pendingRequests(studentId));
    return (data as List).map((e) => PendingRequestModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> acceptFriendship(String friendshipId) async {
    await _api.patch(ApiConstants.acceptFriendship(friendshipId));
  }

  Future<void> declineFriendship(String friendshipId) async {
    await _api.delete(ApiConstants.declineFriendship(friendshipId));
  }

  Future<List<RecommendationModel>> getRecommendations(String studentId) async {
    final data = await _api.get(ApiConstants.recommendFriends(studentId, limit: 15));
    return (data as List).map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConnectionPathModel?> getConnectionPath(String fromId, String toId) async {
    try {
      final data = await _api.get(ApiConstants.connectionPath(fromId, toId));
      return ConnectionPathModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
