import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/gradient_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic>? _expenseSummary;
  Map<String, dynamic>? _workoutSummary;
  List<dynamic>? _moodHistory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiClient().getExpenseSummary(),
        ApiClient().getWorkoutSummary(),
        ApiClient().getMoodHistory(),
      ]);
      if (mounted) {
        setState(() {
          _expenseSummary = results[0] as Map<String, dynamic>;
          _workoutSummary = results[1] as Map<String, dynamic>;
          _moodHistory = results[2] as List<dynamic>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _moodEmoji(String? mood) {
    const map = {
      'Happy': '😊', 'Sad': '😢', 'Anxious': '😰', 'Angry': '😠',
      'Tired': '😴', 'Excited': '🤩', 'Calm': '😌', 'Bored': '😐',
    };
    return map[mood] ?? '🙂';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.yellow,
        backgroundColor: AppTheme.surface,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: AppTheme.background,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_greeting,',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              user?.displayName?.split(' ').first ?? 'User',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Avatar
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          backgroundColor: AppTheme.yellow,
                          child: user?.photoURL == null
                              ? Text(
                                  (user?.displayName?.substring(0, 1) ?? 'U').toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _loading
                    ? const _LoadingPlaceholder()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Hero balance-style expense card (FamPay style)
                          _HeroCard(
                            totalSpent: (_expenseSummary?['totalSpent'] as num?)?.toDouble() ?? 0,
                          ),
                          const SizedBox(height: 20),

                          // Quick action buttons
                          Row(
                            children: [
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.add_card_rounded,
                                  label: 'Add Expense',
                                  color: AppTheme.yellow,
                                  onTap: () => context.go('/expenses'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.fitness_center_rounded,
                                  label: 'Log Workout',
                                  color: AppTheme.orange,
                                  onTap: () => context.go('/workouts'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.mood_rounded,
                                  label: 'Check Mood',
                                  color: AppTheme.pink,
                                  onTap: () => context.go('/mood'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Stats row
                          Text('This Week', style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          )),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Workouts',
                                  value: '${(_workoutSummary?['totalMinutes'] as num?)?.toInt() ?? 0} min',
                                  icon: Icons.local_fire_department_rounded,
                                  iconColor: AppTheme.orange,
                                  gradient: AppTheme.cardGradient1,
                                  subtitle: '${(_workoutSummary?['totalCalories'] as num?)?.toInt() ?? 0} kcal',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Last Mood',
                                  value: _moodHistory != null && _moodHistory!.isNotEmpty
                                      ? _moodEmoji(_moodHistory!.first['mood'])
                                      : '—',
                                  icon: Icons.bubble_chart_rounded,
                                  iconColor: AppTheme.pink,
                                  gradient: AppTheme.cardGradient2,
                                  subtitle: _moodHistory != null && _moodHistory!.isNotEmpty
                                      ? _moodHistory!.first['mood']
                                      : 'No logs yet',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Top expense categories
                          if (_expenseSummary != null &&
                              (_expenseSummary!['categories'] as List).isNotEmpty) ...[
                            Text('Top Spending', style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            )),
                            const SizedBox(height: 12),
                            ...((_expenseSummary!['categories'] as List).take(3).map(
                              (cat) => _CategoryRow(
                                name: cat['_id'],
                                total: (cat['total'] as num).toDouble(),
                                totalAll: (_expenseSummary!['totalSpent'] as num).toDouble(),
                              ),
                            )),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double totalSpent;
  const _HeroCard({required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.yellow.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spent',
            style: GoogleFonts.outfit(
              color: Colors.black.withOpacity(0.65),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${totalSpent.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroChip(icon: Icons.trending_up, label: 'This Month'),
              const SizedBox(width: 8),
              _HeroChip(icon: Icons.calendar_today_rounded, label: 'All Time'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black87),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final double total;
  final double totalAll;

  const _CategoryRow({required this.name, required this.total, required this.totalAll});

  @override
  Widget build(BuildContext context) {
    final pct = totalAll > 0 ? total / totalAll : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14)),
              Text('₹${total.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                      color: AppTheme.yellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: AppTheme.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.yellow),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(color: AppTheme.yellow),
      ),
    );
  }
}
