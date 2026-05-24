import 'package:flutter/foundation.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/club_repository.dart';

class ClubProvider extends ChangeNotifier {
  final _clubRepo = ClubRepository();
  final _eventRepo = EventRepository();

  List<ClubModel> _clubs = [];
  List<EventModel> _events = [];
  List<EventModel> _recommendedEvents = [];
  bool _clubsLoading = false;
  bool _eventsLoading = false;

  List<ClubModel> get clubs => _clubs;
  List<EventModel> get events => _events;
  List<EventModel> get recommendedEvents => _recommendedEvents;
  bool get clubsLoading => _clubsLoading;
  bool get eventsLoading => _eventsLoading;

  Future<void> loadClubs(String studentId) async {
    _clubsLoading = true;
    notifyListeners();
    try {
      _clubs = await _clubRepo.getClubs(studentId: studentId);
    } finally {
      _clubsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents(String studentId) async {
    _eventsLoading = true;
    notifyListeners();
    try {
      _events = await _eventRepo.getEvents(studentId: studentId);
      _recommendedEvents = await _eventRepo.getRecommendedEvents(studentId);
    } finally {
      _eventsLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleClubMembership(String studentId, ClubModel club) async {
    final idx = _clubs.indexWhere((c) => c.clubId == club.clubId);
    if (idx == -1) return;

    final wasMember = _clubs[idx].isMember;
    _clubs[idx] = _clubs[idx].copyWith(
      isMember: !wasMember,
      memberCount: wasMember ? _clubs[idx].memberCount - 1 : _clubs[idx].memberCount + 1,
    );
    notifyListeners();

    try {
      if (wasMember) {
        await _clubRepo.leaveClub(club.clubId, studentId);
      } else {
        await _clubRepo.joinClub(club.clubId, studentId);
      }
    } catch (_) {
      // Revert
      _clubs[idx] = _clubs[idx].copyWith(
        isMember: wasMember,
        memberCount: wasMember ? _clubs[idx].memberCount + 1 : _clubs[idx].memberCount - 1,
      );
      notifyListeners();
    }
  }

  Future<void> toggleEventAttendance(String studentId, EventModel event) async {
    _updateEventList(_events, studentId, event);
    _updateEventList(_recommendedEvents, studentId, event);
  }

  Future<void> _updateEventList(
    List<EventModel> list, String studentId, EventModel event) async {
    final idx = list.indexWhere((e) => e.eventId == event.eventId);
    if (idx == -1) return;

    final wasAttending = list[idx].isAttending;
    list[idx] = list[idx].copyWith(
      isAttending: !wasAttending,
      attendeeCount: wasAttending ? list[idx].attendeeCount - 1 : list[idx].attendeeCount + 1,
    );
    notifyListeners();

    try {
      if (wasAttending) {
        await _eventRepo.leaveEvent(event.eventId, studentId);
      } else {
        await _eventRepo.attendEvent(event.eventId, studentId);
      }
    } catch (_) {
      list[idx] = list[idx].copyWith(
        isAttending: wasAttending,
        attendeeCount: wasAttending ? list[idx].attendeeCount + 1 : list[idx].attendeeCount - 1,
      );
      notifyListeners();
    }
  }

  void clear() {
    _clubs = [];
    _events = [];
    _recommendedEvents = [];
    notifyListeners();
  }
}
