import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';

import 'package:habit_spark/screens/habits/habit_detail_page.dart';
import 'package:habit_spark/screens/habits/create_edit_habit_page.dart';

class CheckInTab extends StatefulWidget {
  final List<Habit> habits;
  final String userId;
  final HabitService habitService;
  final VoidCallback onAddHabit;

  const CheckInTab({
    super.key,
    required this.habits,
    required this.userId,
    required this.habitService,
    required this.onAddHabit,
  });

  @override
  State<CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<CheckInTab> {
  void _confirmDelete(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text('Delete Habit?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              widget.habitService.deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.secondaryLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E3E),
            Color(0xFF4A6666),
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Activity Feed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),

          // Smart Nudges
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SmartNudgeCard(),
            ),
          ),

          // Weekly Dashboard
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _WeeklyGoalsDashboard(),
            ),
          ),

          // Section Header: Generic Habits Checklist (with CRUD)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Habits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onAddHabit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Habit List
          widget.habits.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 16,
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.checklist, size: 48, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              "No habits yet",
                              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap the + button to add one",
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _GlassHabitCard(
                        habit: widget.habits[index],
                        userId: widget.userId,
                        habitService: widget.habitService,
                        onEditTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateEditHabitPage(
                              habit: widget.habits[index],
                              userId: widget.userId,
                            ),
                          ),
                        ),
                        onDeleteTap: () => _confirmDelete(widget.habits[index]),
                      ),
                      childCount: widget.habits.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Text(
                'Recent Activities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Running Tracker
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _RunningActivityCard(),
            ),
          ),

          // Gym Tracker
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: _GymActivityCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _GlassHabitCard extends StatefulWidget {
  final Habit habit;
  final String userId;
  final HabitService habitService;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const _GlassHabitCard({
    required this.habit,
    required this.userId,
    required this.habitService,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  State<_GlassHabitCard> createState() => _GlassHabitCardState();
}

class _GlassHabitCardState extends State<_GlassHabitCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDone = widget.habit.isDone;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDone ? AppColors.success.withOpacity(0.2) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? AppColors.success.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () async {
                          if (widget.habit.habitType == 'checkbox') {
                            await widget.habitService.toggleHabit(
                              widget.habit.id,
                              widget.habit.isDone,
                              widget.userId,
                            );
                          } else {
                            _showLoggingDialog(context);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? AppColors.success : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? AppColors.success
                                  : Colors.white70,
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.name,
                              style: AppTextStyles.heading5.copyWith(
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? Colors.white70
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              isDone ? 'Completed ✓' : 'Tap checkbox to complete',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDone
                                    ? AppColors.success
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                // Expanded actions
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Row(
                            children: [
                              _ActionBtn(
                                label: 'Edit',
                                icon: Icons.edit_outlined,
                                color: AppColors.primaryLight,
                                onTap: widget.onEditTap,
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Delete',
                                icon: Icons.delete_outline,
                                color: AppColors.secondaryLight,
                                onTap: widget.onDeleteTap,
                              ),
                              const SizedBox(width: 8),
                              _ActionBtn(
                                label: 'Details',
                                icon: Icons.info_outline,
                                color: AppColors.accent,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitDetailPage(habit: widget.habit),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoggingDialog(BuildContext context) {
    final TextEditingController _valueController = TextEditingController();
    final TextEditingController _notesController = TextEditingController();
    final isDone = widget.habit.isDone;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          isDone ? 'Update Log' : 'Log ${widget.habit.name}',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.habit.targetValue != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Daily Goal: ${widget.habit.targetValue} ${widget.habit.unit}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Value (${widget.habit.unit})',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryLight)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryLight)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final value = double.tryParse(_valueController.text);
              if (value != null) {
                await widget.habitService.toggleHabit(
                  widget.habit.id,
                  widget.habit.isDone,
                  widget.userId,
                  distance: widget.habit.habitType == 'distance' ? value : null,
                  weight: widget.habit.habitType == 'weight' ? value : null,
                  value: widget.habit.habitType == 'time' ? value : null,
                  notes: _notesController.text,
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(isDone ? 'Update' : 'Log', style: const TextStyle(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartNudgeCard extends StatelessWidget {
  const _SmartNudgeCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      opacity: 0.12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coach Insight', style: AppTextStyles.labelMedium.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  "You're 2 runs away from your weekly goal! Perfect weather today 🌤",
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalsDashboard extends StatelessWidget {
  const _WeeklyGoalsDashboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(Icons.directions_run, '15.2', 'km run', AppColors.primaryLight),
            const SizedBox(width: 12),
            _buildStatCard(Icons.fitness_center, '4', 'workouts', AppColors.secondaryLight),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(Icons.local_fire_department, '7', 'day streak', AppColors.accent),
            const SizedBox(width: 12),
            _buildStatCard(Icons.trending_up, '2,450', 'kcal burned', AppColors.primaryLight),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        opacity: 0.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.heading3.copyWith(color: Colors.white)),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _RunningActivityCard extends StatelessWidget {
  const _RunningActivityCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_run, color: AppColors.primaryLight),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Morning Run', style: AppTextStyles.heading5.copyWith(color: Colors.white)),
                      Text('Today at 7:30 AM', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text('PR Pace', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Map Placeholder
          Container(
            height: 140,
            width: double.infinity,
            color: Colors.white.withOpacity(0.05),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Faux path
                CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _RoutePainter(color: AppColors.primaryLight),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text('View Full Map', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Distance', '5.2 km'),
                _buildStat('Pace', '5:15 /km'),
                _buildStat('Time', '27:18'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.heading4.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final Color color;
  _RoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.1, size.width * 0.7, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.4, size.width * 0.9, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GymActivityCard extends StatelessWidget {
  const _GymActivityCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center, color: AppColors.secondaryLight),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Heavy Push Day', style: AppTextStyles.heading5.copyWith(color: Colors.white)),
                      Text('Yesterday, 1h 15m', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.white.withOpacity(0.1), height: 1),

          // Exercises
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildExerciseRow('Bench Press', '4 × 8-10', '85 kg', true),
                const SizedBox(height: 16),
                _buildExerciseRow('Overhead Press', '3 × 10', '50 kg', false),
                const SizedBox(height: 16),
                _buildExerciseRow('Incline Dumbbell', '3 × 12', '32 kg', false),
              ],
            ),
          ),
          
          // Action
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Text(
                'View Workout Details →',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(String name, String sets, String weight, bool isPR) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                if (isPR) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('PR', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(sets, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          ],
        ),
        Text(weight, style: AppTextStyles.heading5.copyWith(color: Colors.white)),
      ],
    );
  }
}
