import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/post_card.dart';
import 'friends_screen.dart';
import 'friend_requests_screen.dart';
import 'connection_path_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sid = context.read<AuthProvider>().studentId;
      context.read<FeedProvider>().loadMyPosts(sid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final feed = context.watch<FeedProvider>();
    final student = auth.student;
    if (student == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        onRefresh: () => feed.loadMyPosts(auth.studentId),
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF130F2A), Color(0xFF0D0B1E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              student.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(duration: 400.ms),

                        const SizedBox(height: 12),
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                        ).animate(delay: 100.ms).fadeIn(),
                        const SizedBox(height: 4),
                        Text(
                          '${student.department} · ${student.yearLabel}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ).animate(delay: 150.ms).fadeIn(),

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionButton(
                              icon: Icons.people,
                              label: 'Arkadaşlar',
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const FriendsScreen())),
                            ),
                            const SizedBox(width: 10),
                            _ActionButton(
                              icon: Icons.mail_outline,
                              label: 'İstekler',
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const FriendRequestsScreen())),
                            ),
                            const SizedBox(width: 10),
                            _ActionButton(
                              icon: Icons.hub,
                              label: 'Bağlantı',
                              color: AppColors.secondary,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ConnectionPathScreen())),
                            ),
                          ],
                        ).animate(delay: 200.ms).fadeIn(),

                        const SizedBox(height: 12),

                        // Logout button
                        TextButton.icon(
                          onPressed: () async {
                            await auth.logout();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false);
                          },
                          icon: const Icon(Icons.logout, size: 16, color: AppColors.textDisabled),
                          label: const Text('Çıkış Yap',
                              style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Posts header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    const Text(
                      'Postlarım',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${feed.myPosts.length}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Posts list ────────────────────────────────────────────────────
            if (feed.myPostsLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else if (feed.myPosts.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.post_add, size: 48, color: AppColors.textDisabled),
                        SizedBox(height: 8),
                        Text('Henüz post paylaşmadın',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => PostCard(
                    post: feed.myPosts[i],
                    showDelete: true,
                    onDelete: () async {
                      await feed.loadMyPosts(auth.studentId);
                    },
                  ),
                  childCount: feed.myPosts.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
