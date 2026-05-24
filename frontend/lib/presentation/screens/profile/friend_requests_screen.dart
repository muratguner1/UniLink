import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _repo = StudentRepository();
  List<PendingRequestModel> _requests = [];
  bool _loading = true;
  final Set<String> _processing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sid = context.read<AuthProvider>().studentId;
      _requests = await _repo.getPendingRequests(sid);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _accept(PendingRequestModel req) async {
    setState(() => _processing.add(req.friendshipId));
    try {
      await _repo.acceptFriendship(req.friendshipId);
      setState(() => _requests.removeWhere((r) => r.friendshipId == req.friendshipId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${req.name} ile arkadaş oldunuz!')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _processing.remove(req.friendshipId));
    }
  }

  Future<void> _decline(PendingRequestModel req) async {
    setState(() => _processing.add(req.friendshipId));
    try {
      await _repo.declineFriendship(req.friendshipId);
      setState(() => _requests.removeWhere((r) => r.friendshipId == req.friendshipId));
    } finally {
      setState(() => _processing.remove(req.friendshipId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Gelen İstekler (${_requests.length})')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _requests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_email_unread_outlined,
                          size: 64, color: AppColors.textDisabled),
                      SizedBox(height: 12),
                      Text('Bekleyen istek yok',
                          style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (_, i) {
                    final req = _requests[i];
                    final isProcessing = _processing.contains(req.friendshipId);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  req.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.name,
                                      style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Text(req.department,
                                      style: const TextStyle(
                                          color: AppColors.textMuted, fontSize: 12)),
                                  Text(DateFormatter.timeAgo(req.since),
                                      style: const TextStyle(
                                          color: AppColors.textDisabled, fontSize: 11)),
                                ],
                              ),
                            ),
                            if (isProcessing)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: AppColors.success, size: 28),
                                    onPressed: () => _accept(req),
                                    tooltip: 'Kabul Et',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: AppColors.textDisabled, size: 28),
                                    onPressed: () => _decline(req),
                                    tooltip: 'Reddet',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 60).ms).fadeIn().slideY(begin: 0.05, end: 0);
                  },
                ),
    );
  }
}
