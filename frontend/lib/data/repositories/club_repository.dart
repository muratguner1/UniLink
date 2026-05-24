import '../models/club_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ClubRepository {
  final _api = ApiService();

  Future<List<ClubModel>> getClubs({String? studentId}) async {
    final data = await _api.get(ApiConstants.clubs(studentId: studentId));
    return (data as List).map((e) => ClubModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> joinClub(String clubId, String studentId) async {
    await _api.post(ApiConstants.joinClub(clubId, studentId));
  }

  Future<void> leaveClub(String clubId, String studentId) async {
    await _api.delete(ApiConstants.leaveClub(clubId, studentId));
  }
}

class EventRepository {
  final _api = ApiService();

  Future<List<EventModel>> getEvents({String? studentId}) async {
    final data = await _api.get(ApiConstants.events(studentId: studentId));
    return (data as List).map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EventModel>> getRecommendedEvents(String studentId) async {
    final data = await _api.get(ApiConstants.recommendEvents(studentId));
    return (data as List).map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> attendEvent(String eventId, String studentId) async {
    await _api.post(ApiConstants.attendEvent(eventId, studentId));
  }

  Future<void> leaveEvent(String eventId, String studentId) async {
    await _api.delete(ApiConstants.leaveEvent(eventId, studentId));
  }
}
