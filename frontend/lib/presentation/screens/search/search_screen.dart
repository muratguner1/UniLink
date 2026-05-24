import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/recommendation_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _repo = StudentRepository();
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  List<StudentModel> _results = [];
  List<RecommendationModel> _recommendations = [];
  bool _searching = false;
  bool _recsLoading = false;
  bool _recsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.index == 1 && !_recsLoaded) _loadRecommendations();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      _results = await _repo.search(q);
    } catch (_) {}
    setState(() => _searching = false);
  }

  Future<void> _loadRecommendations() async {
    setState(() => _recsLoading = true);
    try {
      final sid = context.read<AuthProvider>().studentId;
      _recommendations = await _repo.getRecommendations(sid);
      _recsLoaded = true;
    } catch (_) {}
    setState(() => _recsLoading = false);
  }

  Future<void> _sendRequest(String targetId) async {
    final sid = context.read<AuthProvider>().studentId;
    try {
      await _repo.sendFriendRequest(sid, targetId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Arkadaşlık isteği gönderildi!')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keşfet'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Arama'),
            Tab(text: 'Öneriler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _SearchTab(
            ctrl: _searchCtrl,
            results: _results,
            searching: _searching,
            onSearch: _search,
            onAdd: _sendRequest,
          ),
          _RecommendationsTab(
            recommendations: _recommendations,
            loading: _recsLoading,
            onAdd: (id) => _sendRequest(id),
          ),
        ],
      ),
    );
  }
}

// ── Search Tab ────────────────────────────────────────────────────────────────

class _SearchTab extends StatelessWidget {
  final TextEditingController ctrl;
  final List<StudentModel> results;
  final bool searching;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onAdd;

  const _SearchTab({
    required this.ctrl,
    required this.results,
    required this.searching,
    required this.onSearch,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: ctrl,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Ada veya bölüme göre ara...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        ctrl.clear();
                        onSearch('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (searching)
          const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else if (results.isEmpty && ctrl.text.isNotEmpty)
          const Expanded(
            child: Center(
              child: Text('Sonuç bulunamadı', style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final s = results[i];
                return ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        s.initials,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  title: Text(s.name, style: const TextStyle(color: AppColors.text)),
                  subtitle: Text('${s.department} · ${s.yearLabel}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
                    onPressed: () => onAdd(s.studentId),
                  ),
                ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.05, end: 0);
              },
            ),
          ),
      ],
    );
  }
}

// ── Recommendations Tab ────────────────────────────────────────────────────────

class _RecommendationsTab extends StatelessWidget {
  final List<RecommendationModel> recommendations;
  final bool loading;
  final ValueChanged<String> onAdd;

  const _RecommendationsTab({
    required this.recommendations,
    required this.loading,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (recommendations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textDisabled),
            SizedBox(height: 12),
            Text('Henüz öneri yok', style: TextStyle(color: AppColors.textMuted)),
            SizedBox(height: 6),
            Text(
              'Daha fazla arkadaş ekleyerek\ngrafı genişlet!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: recommendations.length,
      itemBuilder: (_, i) => RecommendationCard(
        rec: recommendations[i],
        onAdd: () => onAdd(recommendations[i].studentId),
      ),
    );
  }
}
