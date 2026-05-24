import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/club_provider.dart';
import '../../widgets/club_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cp = context.watch<ClubProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => cp.loadEvents(auth.studentId),
          ),
        ],
      ),
      body: cp.eventsLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              onRefresh: () => cp.loadEvents(auth.studentId),
              child: CustomScrollView(
                slivers: [
                  // Önerilen Etkinlikler
                  if (cp.recommendedEvents.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: '✨ Sana Özel',
                        subtitle: 'Kulüplerinden öneriler',
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => EventCard(
                          event: cp.recommendedEvents[i],
                          onToggle: () => cp.toggleEventAttendance(
                              auth.studentId, cp.recommendedEvents[i]),
                        ),
                        childCount: cp.recommendedEvents.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ],

                  // Tüm Etkinlikler
                  const SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: '📅 Tüm Etkinlikler',
                      subtitle: 'Tarihe göre sıralı',
                    ),
                  ),
                  if (cp.events.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Etkinlik bulunamadı',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => EventCard(
                          event: cp.events[i],
                          onToggle: () => cp.toggleEventAttendance(
                              auth.studentId, cp.events[i]),
                        ),
                        childCount: cp.events.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              )),
          Text(subtitle,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
