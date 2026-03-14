import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  List<dynamic> _workouts = [];
  Map<String, dynamic>? _summary;
  bool _loading = true;

  static const _types = [
    'Running', 'Cycling', 'Strength', 'Yoga', 'Swimming', 'Walking', 'HIIT', 'Other'
  ];

  static const _typeIcons = {
    'Running': Icons.directions_run_rounded,
    'Cycling': Icons.directions_bike_rounded,
    'Strength': Icons.fitness_center_rounded,
    'Yoga': Icons.self_improvement_rounded,
    'Swimming': Icons.pool_rounded,
    'Walking': Icons.directions_walk_rounded,
    'HIIT': Icons.local_fire_department_rounded,
    'Other': Icons.sports_rounded,
  };

  static const _typeColors = {
    'Running': AppTheme.orange,
    'Cycling': AppTheme.blue,
    'Strength': AppTheme.yellow,
    'Yoga': AppTheme.pink,
    'Swimming': AppTheme.blue,
    'Walking': AppTheme.green,
    'HIIT': AppTheme.orange,
    'Other': AppTheme.textSecondary,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiClient().getWorkouts(),
        ApiClient().getWorkoutSummary(),
      ]);
      if (mounted) {
        setState(() {
          _workouts = results[0] as List;
          _summary = results[1] as Map<String, dynamic>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddWorkoutSheet(types: _types, onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Workouts'), backgroundColor: AppTheme.background),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppTheme.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Log', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.orange,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryChip(
                              label: 'Total Time',
                              value: '${((_summary?['totalMinutes'] as num?)?.toInt() ?? 0)} min',
                              color: AppTheme.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryChip(
                              label: 'Calories',
                              value: '${((_summary?['totalCalories'] as num?)?.toInt() ?? 0)} kcal',
                              color: AppTheme.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: _workouts.isEmpty
                        ? SliverToBoxAdapter(
                            child: _EmptyState(
                              icon: Icons.fitness_center_rounded,
                              message: 'No workouts yet.\nStart logging your sessions!',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => _WorkoutTile(
                                workout: _workouts[i],
                                icon: _typeIcons[_workouts[i]['type']] ?? Icons.sports_rounded,
                                color: _typeColors[_workouts[i]['type']] ?? AppTheme.textSecondary,
                                onDelete: () async {
                                  await ApiClient().deleteWorkout(_workouts[i]['_id']);
                                  _load();
                                },
                              ),
                              childCount: _workouts.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final dynamic workout;
  final IconData icon;
  final Color color;
  final VoidCallback onDelete;

  const _WorkoutTile({required this.workout, required this.icon, required this.color, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(workout['date'] ?? '') ?? DateTime.now();
    return Dismissible(
      key: Key(workout['_id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout['type'],
                      style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text('${workout['durationMinutes']} min · ${workout['caloriesBurned']} kcal',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text(DateFormat('d MMM').format(date),
                style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AddWorkoutSheet extends StatefulWidget {
  final List<String> types;
  final VoidCallback onSaved;
  const _AddWorkoutSheet({required this.types, required this.onSaved});

  @override
  State<_AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<_AddWorkoutSheet> {
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _selectedType = 'Running';
  bool _saving = false;

  Future<void> _save() async {
    final duration = int.tryParse(_durationCtrl.text.trim());
    if (duration == null || duration <= 0) return;

    setState(() => _saving = true);
    try {
      await ApiClient().addWorkout({
        'type': _selectedType,
        'durationMinutes': duration,
        'caloriesBurned': int.tryParse(_caloriesCtrl.text.trim()) ?? 0,
        'note': _noteCtrl.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Log Workout',
              style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedType,
            dropdownColor: AppTheme.surface,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Type'),
            items: widget.types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Duration (min)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _caloriesCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange),
              child: _saving
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(children: [
          Icon(icon, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 15)),
        ]),
      ),
    );
  }
}
