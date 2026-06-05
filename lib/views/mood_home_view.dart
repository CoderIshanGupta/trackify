import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/mood_model.dart';
import '../services/app_state.dart';
import '../widgets/app_theme.dart';

class MoodHomeView extends StatefulWidget {
  const MoodHomeView({super.key});

  @override
  State<MoodHomeView> createState() => _MoodHomeViewState();
}

class _MoodHomeViewState extends State<MoodHomeView> {
  final _moodProvider = AppState.moodProvider;
  final _noteController = TextEditingController();

  int _selectedRating = 0; // 0 = none selected
  String _selectedLabel = '';
  String _selectedEmoji = '';

  final List<Map<String, dynamic>> _moodOptions = [
    {'rating': 5, 'label': 'Rad', 'emoji': '😆', 'color': const Color(0xFFFFB800)},
    {'rating': 4, 'label': 'Good', 'emoji': '🙂', 'color': const Color(0xFF00E5FF)},
    {'rating': 3, 'label': 'Meh', 'emoji': '😐', 'color': const Color(0xFF9E9E9E)},
    {'rating': 2, 'label': 'Bad', 'emoji': '😔', 'color': const Color(0xFFFF5252)},
    {'rating': 1, 'label': 'Awful', 'emoji': '😭', 'color': const Color(0xFF7C4DFF)},
  ];

  @override
  void initState() {
    super.initState();
    _moodProvider.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _moodProvider.removeListener(_onStateChange);
    _noteController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _selectMood(int rating, String label, String emoji) {
    setState(() {
      _selectedRating = rating;
      _selectedLabel = label;
      _selectedEmoji = emoji;
    });
  }

  void _logMood() {
    if (_selectedRating == 0) return;

    final newMood = MoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rating: _selectedRating,
      label: _selectedLabel,
      note: _noteController.text.trim(),
      timestamp: DateTime.now(),
      emoji: _selectedEmoji,
    );

    _moodProvider.addMood(newMood);
    AppState.syncAnalytics(); // Recalculate AI insight

    // Reset logger state
    setState(() {
      _selectedRating = 0;
      _selectedLabel = '';
      _selectedEmoji = '';
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mood logged successfully! Check your trends below.'),
        backgroundColor: AppTheme.accentNeon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moods = _moodProvider.moods;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let main background show through
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "How's your mood?",
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Logging your mood unlocks personalized AI insights",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Premium Emoji Selection Grid
             SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               physics: const BouncingScrollPhysics(),
               child: Row(
                 children: _moodOptions.map((opt) {
                   final isSelected = _selectedRating == opt['rating'];
                   final color = opt['color'] as Color;

                   return Padding(
                     padding: const EdgeInsets.only(right: 8.0),
                     child: GestureDetector(
                       onTap: () => _selectMood(opt['rating'], opt['label'], opt['emoji']),
                       child: AnimatedContainer(
                         duration: 200.ms,
                         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                         decoration: BoxDecoration(
                           color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.cardDark,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(
                             color: isSelected ? color : Colors.transparent,
                             width: 2,
                           ),
                           boxShadow: isSelected
                               ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 2)]
                               : [],
                         ),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text(
                               opt['emoji'],
                               style: const TextStyle(fontSize: 28),
                             ).animate(target: isSelected ? 1 : 0).scaleXY(begin: 1.0, end: 1.25, curve: Curves.bounceOut),
                             const SizedBox(height: 8),
                             Text(
                               opt['label'],
                               style: TextStyle(
                                 color: isSelected ? color : AppTheme.textSecondary,
                                 fontSize: 12,
                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                   );
                 }).toList(),
               ),
             ),

            // Collapsible Note Logger
            AnimatedSize(
              duration: 350.ms,
              curve: Curves.easeOutBack,
              child: _selectedRating > 0
                  ? Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: (_moodOptions.firstWhere((e) => e['rating'] == _selectedRating)['color'] as Color)
                              .withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Adding a note about: "$_selectedLabel $_selectedEmoji"',
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'What made you feel this way? (optional)',
                              hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _logMood,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _moodOptions.firstWhere((e) => e['rating'] == _selectedRating)['color'] as Color,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Entry',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // Weekly Mood Trend Chart Section
            const Text(
              "Weekly Trend",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyTrendChart(),

            const SizedBox(height: 32),

            // Logs History Section
            const Text(
              "History Logs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (moods.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    "No mood logs yet. Choose an emotion above to log your first mood!",
                    style: TextStyle(color: Colors.white30, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final log = moods[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.cardDark,
                        width: 1,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left side color code bar
                          Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: log.color,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            log.emoji,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            log.label,
                                            style: TextStyle(
                                              color: log.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _formatTime(log.timestamp),
                                        style: const TextStyle(color: Colors.white30, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  if (log.note.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      log.note,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget to construct the custom drawn premium bar chart
  Widget _buildWeeklyTrendChart() {
    final moods = _moodProvider.moods;
    
    // Grab the last 7 days of moods (or pad with empty data points if we don't have enough)
    // We want a list of 7 slots representing last 7 days.
    final List<Map<String, dynamic>> chartData = [];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      
      // Find a mood that was logged on this calendar date
      final loggedMoods = moods.where((m) {
        return m.timestamp.day == date.day &&
            m.timestamp.month == date.month &&
            m.timestamp.year == date.year;
      }).toList();

      String label = _getDayName(date);
      if (loggedMoods.isNotEmpty) {
        // Use average rating or the latest logged mood for that day
        chartData.add({
          'day': label,
          'rating': loggedMoods.first.rating,
          'color': loggedMoods.first.color,
          'emoji': loggedMoods.first.emoji,
        });
      } else {
        chartData.add({
          'day': label,
          'rating': 0, // 0 height represents empty log
          'color': Colors.white10,
          'emoji': '',
        });
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((data) {
              final rating = data['rating'] as int;
              final color = data['color'] as Color;
              final dayName = data['day'] as String;

              // Compute height dynamically: maximum rating is 5 (corresponds to height 120px)
              final double barHeight = rating > 0 ? (rating / 5) * 120 : 12;

              return Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Track background channel
                        Container(
                          width: 16,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Animated active bar
                        AnimatedContainer(
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                          width: 16,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: rating > 0
                                  ? [color.withValues(alpha: 0.4), color]
                                  : [Colors.white10, Colors.white10],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: rating > 0
                                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 1)]
                                : [],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dayName,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentNeon, size: 16),
              SizedBox(width: 8),
              Text(
                'Bars represent your mood level rating (1 to 5) per day.',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  String _formatTime(DateTime dt) {
    // Basic formatting "2:30 PM" or "Yesterday, 4:15 PM"
    final now = DateTime.now();
    final difference = now.difference(dt).inDays;
    
    String prefix = '';
    if (difference == 0 && now.day == dt.day) {
      prefix = 'Today';
    } else if (difference <= 1 && now.subtract(const Duration(days: 1)).day == dt.day) {
      prefix = 'Yesterday';
    } else {
      prefix = '${dt.day}/${dt.month}';
    }

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';

    return '$prefix at $hour:$minute $ampm';
  }
}