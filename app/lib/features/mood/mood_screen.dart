import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  String? _selectedMood;
  List<String>? _suggestions;
  List<dynamic> _history = [];
  bool _loading = false;
  bool _historyLoading = true;

  static const _moods = [
    {'mood': 'Happy', 'emoji': '😊', 'color': 0xFFFFD700},
    {'mood': 'Sad', 'emoji': '😢', 'color': 0xFF64B5F6},
    {'mood': 'Anxious', 'emoji': '😰', 'color': 0xFFFF7043},
    {'mood': 'Angry', 'emoji': '😠', 'color': 0xFFEF5350},
    {'mood': 'Tired', 'emoji': '😴', 'color': 0xFF9E9E9E},
    {'mood': 'Excited', 'emoji': '🤩', 'color': 0xFFFF4081},
    {'mood': 'Calm', 'emoji': '😌', 'color': 0xFF66BB6A},
    {'mood': 'Bored', 'emoji': '😐', 'color': 0xFF90A4AE},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final h = await ApiClient().getMoodHistory();
      if (mounted) setState(() { _history = h; _historyLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  Future<void> _logMood(String mood) async {
    setState(() { _loading = true; _selectedMood = mood; _suggestions = null; });
    try {
      final res = await ApiClient().logMood(mood);
      if (mounted) {
        setState(() {
          _suggestions = List<String>.from(res['suggestedActivities'] ?? []);
          _loading = false;
        });
        _loadHistory();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Mood & Activities'), backgroundColor: AppTheme.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling?',
                style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Select your mood and get personalized activity suggestions.',
                style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),

            // Mood grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _moods.map((m) {
                final isSelected = _selectedMood == m['mood'];
                final color = Color(m['color'] as int);
                return GestureDetector(
                  onTap: _loading ? null : () => _logMood(m['mood'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.2) : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : AppTheme.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(m['emoji'] as String, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          m['mood'] as String,
                          style: GoogleFonts.outfit(
                            color: isSelected ? color : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // Loading
            if (_loading)
              const Center(child: CircularProgressIndicator(color: AppTheme.pink)),

            // Suggestions from server
            if (_suggestions != null && _suggestions!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3D1A78).withOpacity(0.6),
                      const Color(0xFF1A0D2E).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.pink.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.pink, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Activities for you',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._suggestions!.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(s,
                                  style: GoogleFonts.outfit(
                                      color: AppTheme.textPrimary, fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // History
            Text('Mood History',
                style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_historyLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.yellow))
            else if (_history.isEmpty)
              Text('No mood logs yet.',
                  style: GoogleFonts.outfit(color: AppTheme.textSecondary))
            else
              ...(_history.take(10).map((log) {
                final moodData = _moods.firstWhere(
                    (m) => m['mood'] == log['mood'],
                    orElse: () => _moods.last);
                final color = Color(moodData['color'] as int);
                final date = DateTime.tryParse(log['date'] ?? '') ?? DateTime.now();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(moodData['emoji'] as String, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log['mood'],
                                style: GoogleFonts.outfit(
                                    color: color, fontWeight: FontWeight.w600)),
                            if ((log['suggestedActivities'] as List?)?.isNotEmpty == true)
                              Text(
                                '${(log['suggestedActivities'] as List).length} activities suggested',
                                style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondary, fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${date.day}/${date.month}',
                        style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }
}
