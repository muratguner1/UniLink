import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/models/student_model.dart';
import '../../providers/auth_provider.dart';

class ConnectionPathScreen extends StatefulWidget {
  const ConnectionPathScreen({super.key});

  @override
  State<ConnectionPathScreen> createState() => _ConnectionPathScreenState();
}

class _ConnectionPathScreenState extends State<ConnectionPathScreen> {
  final _repo = StudentRepository();
  final _targetCtrl = TextEditingController();

  ConnectionPathModel? _result;
  String? _error;
  bool _loading = false;
  List<StudentModel> _searchResults = [];
  StudentModel? _selectedTarget;
  bool _searching = false;

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      _searchResults = await _repo.search(q);
    } catch (_) {}
    setState(() => _searching = false);
  }

  Future<void> _findPath() async {
    if (_selectedTarget == null) return;
    final myId = context.read<AuthProvider>().studentId;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      _result = await _repo.getConnectionPath(myId, _selectedTarget!.studentId);
      if (_result == null) _error = 'Bağlantı bulunamadı (6 hop içinde).';
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bağlantı Zinciri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textMuted),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hub, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Neo4j shortestPath algoritması ile iki öğrenci arasındaki en kısa arkadaşlık zincirini bul.',
                      style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            // Search field
            const Text('Hedef Öğrenci Ara',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _targetCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Ada göre ara...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _selectedTarget != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () => setState(() {
                          _selectedTarget = null;
                          _targetCtrl.clear();
                          _searchResults = [];
                          _result = null;
                        }),
                      )
                    : null,
              ),
            ),

            // Search results
            if (_searching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_searchResults.isNotEmpty && _selectedTarget == null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: _searchResults.take(5).map((s) => ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(s.initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                    title: Text(s.name, style: const TextStyle(color: AppColors.text, fontSize: 14)),
                    subtitle: Text(s.department, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    onTap: () => setState(() {
                      _selectedTarget = s;
                      _targetCtrl.text = s.name;
                      _searchResults = [];
                    }),
                  )).toList(),
                ),
              ),

            if (_selectedTarget != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loading ? null : _findPath,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.route, size: 18),
                label: Text(_loading ? 'Aranıyor...' : 'Zinciri Bul'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              ),
            ],

            // ── Result ─────────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_off, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                  ],
                ),
              ).animate().fadeIn(),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          '${_result!.hops} hop uzakta',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Chain visualization
                    _ChainVisualizer(chain: _result!.chain),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('shortestPath Nedir?', style: TextStyle(color: AppColors.text)),
        content: const Text(
          'Neo4j\'nin shortestPath() algoritması, iki node arasındaki en az ilişki sayısıyla ulaşılan yolu bulur.\n\n'
          'UniLink\'te bu, iki öğrenci arasındaki en kısa arkadaşlık zincirini gösterir.',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }
}

class _ChainVisualizer extends StatelessWidget {
  final List<String> chain;
  const _ChainVisualizer({required this.chain});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: [
        for (int i = 0; i < chain.length; i++) ...[
          _PersonChip(name: chain[i], isFirst: i == 0, isLast: i == chain.length - 1),
          if (i < chain.length - 1)
            const Icon(Icons.arrow_forward, color: AppColors.secondary, size: 16),
        ],
      ],
    );
  }
}

class _PersonChip extends StatelessWidget {
  final String name;
  final bool isFirst;
  final bool isLast;

  const _PersonChip({required this.name, this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final color = isFirst || isLast ? AppColors.primary : AppColors.secondary;
    final firstName = name.split(' ').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        firstName,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
