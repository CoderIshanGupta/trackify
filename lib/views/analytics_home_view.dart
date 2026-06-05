import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/analytics_model.dart';
import '../models/expense_model.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';
import 'mood_home_view.dart';

class AnalyticsHomeView extends StatefulWidget {
  const AnalyticsHomeView({super.key});

  @override
  State<AnalyticsHomeView> createState() => _AnalyticsHomeViewState();
}

class _AnalyticsHomeViewState extends State<AnalyticsHomeView> {
  final AuthService _authService = AuthService();
  final _analyticsProvider = AppState.analyticsProvider;
  final _moodProvider = AppState.moodProvider;
  final _expenseProvider = AppState.expenseProvider;

  int _currentTab = 0; // 0 = Analytics Dashboard, 1 = Mood Board

  // Interactive local Habit checklist states
  final List<Map<String, dynamic>> _habits = [
    {'id': '1', 'name': 'Morning Meditation 🧘', 'checked': true},
    {'id': '2', 'name': 'Gym Workout 🏋️', 'checked': true},
    {'id': '3', 'name': 'Drink 3L Water 💧', 'checked': false},
    {'id': '4', 'name': 'Read 10 Pages 📚', 'checked': false},
  ];

  @override
  void initState() {
    super.initState();
    _analyticsProvider.addListener(_onStateChange);
    _moodProvider.addListener(_onStateChange);
    _expenseProvider.addListener(_onStateChange);
    
    // Initial sync
    _recalcStats();
  }

  @override
  void dispose() {
    _analyticsProvider.removeListener(_onStateChange);
    _moodProvider.removeListener(_onStateChange);
    _expenseProvider.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  // Recalculates stats based on checked checkboxes and real logged expenses
  void _recalcStats() {
    final checkedCount = _habits.where((h) => h['checked'] == true).length;
    final habitRate = checkedCount / _habits.length;
    
    _analyticsProvider.updateAnalytics(
      averageMood: _moodProvider.averageMood,
      totalExpenses: _expenseProvider.totalSpent,
      habitRate: habitRate,
    );
  }

  void _toggleHabit(int index) {
    setState(() {
      _habits[index]['checked'] = !_habits[index]['checked'];
    });
    _recalcStats();
  }

  void _deleteHabit(int index) {
    setState(() {
      _habits.removeAt(index);
    });
    _recalcStats();
  }

  void _showAddHabitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Habit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "E.g. Code for 1 hour 💻",
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF121212),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white30)),
            ),
            ElevatedButton(
               onPressed: () {
                 final name = controller.text.trim();
                 if (name.isNotEmpty) {
                   setState(() {
                     _habits.add({
                       'id': DateTime.now().millisecondsSinceEpoch.toString(),
                       'name': name,
                       'checked': false,
                     });
                   });
                   _recalcStats();
                 }
                 Navigator.pop(context);
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.accentNeon,
                 foregroundColor: Colors.black,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
               ),
               child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Action to trigger premium custom Bottom Sheet to add real expense manually
  void _showAddExpenseSheet() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = 'Food';

    final List<Map<String, dynamic>> categories = [
      {'name': 'Food', 'emoji': '🍔', 'color': const Color(0xFFFFB800)},
      {'name': 'Shopping', 'emoji': '🛍️', 'color': const Color(0xFF00E5FF)},
      {'name': 'Travel', 'emoji': '✈️', 'color': const Color(0xFFFF5252)},
      {'name': 'Entertainment', 'emoji': '🍿', 'color': const Color(0xFF7C4DFF)},
      {'name': 'Bills', 'emoji': '📄', 'color': const Color(0xFF4CAF50)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Add Daily Expense",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount input field
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "\$0.00",
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category selection horizontal scroll
                    const Text(
                      "Category",
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat['name'];
                          final color = cat['color'] as Color;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedCategory = cat['name'];
                                });
                              },
                              child: AnimatedContainer(
                                duration: 150.ms,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFF121212),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? color : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(cat['emoji'], style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat['name'],
                                      style: TextStyle(
                                        color: isSelected ? color : Colors.white70,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
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
                    const SizedBox(height: 20),

                    // Note/Description field
                    const Text(
                      "Note",
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "What was this for?",
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: () {
                        final amtText = amountController.text.trim();
                        final amount = double.tryParse(amtText) ?? 0.0;

                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Please enter a valid expense amount."),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          return;
                        }

                        final newExpense = ExpenseModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          amount: amount,
                          category: selectedCategory,
                          note: noteController.text.trim(),
                          timestamp: DateTime.now(),
                        );

                        _expenseProvider.addExpense(newExpense);
                        _recalcStats();

                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Logged \$${amount.toStringAsFixed(2)} under $selectedCategory!"),
                            backgroundColor: AppTheme.accentNeon,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentNeon,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Log Expense",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final User? user = _authService.currentUser;
    final String displayName = user?.displayName ?? user?.email?.split('@').first ?? "User";
    final analytics = _analyticsProvider.analytics;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Neon Orbs Background
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentNeon.withValues(alpha: 0.08),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
                  begin: 1.0,
                  end: 1.25,
                  duration: 6.seconds,
                  curve: Curves.easeInOut,
                ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
                  begin: 1.0,
                  end: 1.2,
                  duration: 5.seconds,
                  curve: Curves.easeInOut,
                ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Global Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.accentNeon.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppTheme.accentNeon,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hey, $displayName",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Welcome to your space",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _handleSignOut,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white60,
                          size: 20,
                        ),
                        tooltip: 'Logout Account',
                      ),
                    ],
                  ),
                ),

                // Main Views switcher
                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      _buildAnalyticsDashboard(theme, analytics),
                      const MoodHomeView(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80), // Clear space for floating nav bar
              ],
            ),
          ),

          // Floating Tab Bar
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildFloatingTabBar(),
          ),
        ],
      ),
    );
  }

  // Floating Tab navigation bar resembling FamPay
  Widget _buildFloatingTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(
            index: 0,
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            label: "Overview",
          ),
          _buildTabItem(
            index: 1,
            icon: Icons.mood_outlined,
            activeIcon: Icons.mood_rounded,
            label: "Moods",
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentNeon.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.accentNeon : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.accentNeon : Colors.white38,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard Overview Section (Tab 0)
  Widget _buildAnalyticsDashboard(ThemeData theme, AnalyticsModel? analytics) {
    if (analytics == null) return const SizedBox.shrink();
    final recentExpenses = _expenseProvider.expenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Gradient Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E2400), Color(0xFF1E1E1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.accentNeon.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL EXPENSE LOG",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddExpenseSheet,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentNeon.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.accentNeon,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "\$${analytics.totalExpenses.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recentExpenses.isEmpty
                          ? "No expenses logged yet"
                          : "${recentExpenses.length} transactions recorded",
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentNeon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: AppTheme.accentNeon, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            recentExpenses.isEmpty ? "0 entries" : "Live",
                            style: const TextStyle(
                              color: AppTheme.accentNeon,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Double Stats widgets (Mood Avg and Habits rate)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "Avg Mood",
                  value: "${analytics.averageMoodRating}",
                  subtext: _getMoodSummaryText(analytics.averageMoodRating),
                  icon: Icons.mood_rounded,
                  color: const Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: "Habit Streak",
                  value: "${(analytics.habitCompletionRate * 100).toInt()}%",
                  subtext: "${_habits.where((h) => h['checked'] == true).length}/${_habits.length} Checked",
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTheme.accentNeon,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // AI Smart Insights Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1B3D), Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.cyanAccent,
                    size: 24,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.9, end: 1.1, duration: 2.seconds),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TRACKIFY AI",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analytics.aiInsight,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Interactive Habit Checklists Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Habits",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _showAddHabitDialog,
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentNeon, size: 22),
                tooltip: 'Add Custom Habit',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_habits.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "No habits tracked today. Tap '+' to start!",
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final isChecked = habit['checked'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked ? AppTheme.accentNeon.withValues(alpha: 0.15) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _toggleHabit(index),
                    leading: IconButton(
                      onPressed: () => _toggleHabit(index),
                      icon: Icon(
                        isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        color: isChecked ? AppTheme.accentNeon : Colors.white30,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      habit['name'],
                      style: TextStyle(
                        color: isChecked ? Colors.white : Colors.white70,
                        fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _deleteHabit(index),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 18),
                          tooltip: 'Remove Habit',
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isChecked ? AppTheme.accentNeon.withValues(alpha: 0.3) : Colors.white10,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1);
              },
            ),

          const SizedBox(height: 24),

          // Real manual expenses section!
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Expenses",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddExpenseSheet,
                icon: const Icon(Icons.add, color: AppTheme.accentNeon, size: 16),
                label: const Text(
                  "Add New",
                  style: TextStyle(color: AppTheme.accentNeon, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentExpenses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "No daily expenses logged. Tap 'Add New' to log real spent!",
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentExpenses.length,
              itemBuilder: (context, index) {
                final expense = recentExpenses[index];
                final color = _getCategoryColor(expense.category);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Category Emoji Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getCategoryEmoji(expense.category),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title / Note / Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.note.isEmpty ? expense.category : expense.note,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expense.category,
                              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // Amount / Delete action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "-\$${expense.amount.toStringAsFixed(2)}",
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              _expenseProvider.deleteExpense(expense);
                              _recalcStats();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Expense entry deleted successfully."),
                                  backgroundColor: Colors.white24,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.1);
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Double stats metric card builder helper
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodSummaryText(double rating) {
    if (rating >= 4.5) return "Fantastic! 😆";
    if (rating >= 3.5) return "Good Vibes 🙂";
    if (rating >= 2.5) return "Cruising 😐";
    if (rating >= 1.5) return "Bumpy days 😔";
    return "Tough times 😭";
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFFB800);
      case 'Shopping':
        return const Color(0xFF00E5FF);
      case 'Travel':
        return const Color(0xFFFF5252);
      case 'Entertainment':
        return const Color(0xFF7C4DFF);
      case 'Bills':
        return const Color(0xFF4CAF50);
      default:
        return Colors.white70;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Food':
        return '🍔';
      case 'Shopping':
        return '🛍️';
      case 'Travel':
        return '✈️';
      case 'Entertainment':
        return '🍿';
      case 'Bills':
        return '📄';
      default:
        return '💰';
    }
  }
}