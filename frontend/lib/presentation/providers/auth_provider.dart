import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = StudentRepository();

  StudentModel? _student;
  bool _loading = false;
  String? _error;

  StudentModel? get student => _student;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _student != null;
  String get studentId => _student?.studentId ?? '';

  // ── Login ────────────────────────────────────────────────────────────────────

  Future<bool> login(String studentId, String email) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _student = await _repo.login(studentId.trim(), email.trim());
      await _saveSession(_student!);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────────

  Future<bool> register({
    required String studentId,
    required String name,
    required String department,
    required int year,
    required String email,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _student = await _repo.register(
        studentId: studentId.trim(),
        name: name.trim(),
        department: department,
        year: year,
        email: email.trim(),
      );
      await _saveSession(_student!);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Session persistence ────────────────────────────────────────────────────────

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final sid = prefs.getString('studentId');
    final dept = prefs.getString('department');
    final name = prefs.getString('name');
    final year = prefs.getInt('year');

    if (sid != null && name != null && dept != null && year != null) {
      _student = StudentModel(
        studentId: sid,
        name: name,
        department: dept,
        year: year,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _saveSession(StudentModel s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentId', s.studentId);
    await prefs.setString('name', s.name);
    await prefs.setString('department', s.department);
    await prefs.setInt('year', s.year);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _student = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
