import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/club_provider.dart';
import '../../widgets/club_card.dart';

class ClubsScreen extends StatelessWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final clubs = context.watch<ClubProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kulüpler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => clubs.loadClubs(auth.studentId),
          ),
        ],
      ),
      body: clubs.clubsLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : clubs.clubs.isEmpty
              ? const Center(
                  child: Text('Kulüp bulunamadı', style: TextStyle(color: AppColors.textMuted)),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  onRefresh: () => clubs.loadClubs(auth.studentId),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            _StatChip(
                              label: '${clubs.clubs.length} Kulüp',
                              icon: Icons.groups,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: '${clubs.clubs.where((c) => c.isMember).length} Üye',
                              icon: Icons.check_circle_outline,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: clubs.clubs.length,
                          itemBuilder: (_, i) => ClubCard(
                            club: clubs.clubs[i],
                            onToggle: () => clubs.toggleClubMembership(
                                auth.studentId, clubs.clubs[i]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
