import 'package:flutter/material.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/auth_service.dart';

class DailyCheckInPage extends StatefulWidget {
  const DailyCheckInPage({super.key});

  @override
  State<DailyCheckInPage> createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage>
    with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  final AuthService _authService = AuthService();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _userId => _authService.currentUser?.uid ?? '';

  Future<void> _toggleHabit(Habit habit) async {
    await _habitService.toggleHabit(habit.id, habit.isDone, _userId);
  }

  Future<void> _markAllDone(List<Habit> habits) async {
    final allDone = habits.every((h) => h.isDone == true);
    if (allDone) return;

    setState(() => _isMarkingAll = true);

    for (final habit in habits) {
      if (habit.isDone != true) {
        await _habitService.toggleHabit(habit.id, false, _userId);
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }

    setState(() => _isMarkingAll = false);

    if (mounted) {
      _showCompletionCelebration();
    }
  }

  void _showCompletionCelebration() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text(
                'All Done!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve completed all your habits for today. Keep it up!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getHabitIcon(Habit habit) {
    if (habit.icon != null) {
      switch (habit.icon) {
        case 'directions_run':   return Icons.directions_run;
        case 'fitness_center':  return Icons.fitness_center;
        case 'self_improvement':return Icons.self_improvement;
        case 'menu_book':       return Icons.menu_book;
        case 'water_drop':      return Icons.water_drop;
        case 'restaurant':      return Icons.restaurant;
        case 'bedtime':         return Icons.bedtime;
        case 'school':          return Icons.school;
        case 'code':            return Icons.code;
        case 'music_note':      return Icons.music_note;
        case 'brush':           return Icons.brush;
        case 'camera_alt':      return Icons.camera_alt;
        case 'favorite':        return Icons.favorite;
        case 'wb_sunny':        return Icons.wb_sunny;
        case 'nightlight':      return Icons.nightlight;
        case 'local_cafe':      return Icons.local_cafe;
      }
    }
    final name = habit.name.toLowerCase();
    if (name.contains('run') || name.contains('jog'))       return Icons.directions_run;
    if (name.contains('read'))                               return Icons.menu_book;
    if (name.contains('water') || name.contains('drink'))   return Icons.water_drop;
    if (name.contains('exercise') || name.contains('workout')) return Icons.fitness_center;
    if (name.contains('meditate') || name.contains('yoga')) return Icons.self_improvement;
    if (name.contains('sleep'))                              return Icons.bedtime;
    if (name.contains('eat') || name.contains('meal'))      return Icons.restaurant;
    if (name.contains('study') || name.contains('learn'))   return Icons.school;
    if (name.contains('walk'))                               return Icons.directions_walk;
    if (name.contains('code') || name.contains('program'))  return Icons.code;
    return Icons.check_circle_outline;
  }

  List<Color> _getGradientColors(int index) {
    final gradients = [
      [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
      [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      [const Color(0xFFFF9A56), const Color(0xFFFF6A88)],
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final dateStr =
        '${weekDays[(today.weekday - 1) % 7]}, ${today.day} ${months[today.month - 1]}';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: StreamBuilder<List<Habit>>(
          stream: _habitService.getHabitsStream(_userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
              );
            }

            final habits = snapshot.data ?? [];
            final completedCount = habits.where((h) => h.isDone == true).length;
            final totalCount = habits.length;
            final allDone = totalCount > 0 && completedCount == totalCount;
            final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Check-In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Completion badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: allDone
                              ? const Color(0xFF4ECDC4).withOpacity(0.15)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: allDone
                                ? const Color(0xFF4ECDC4).withOpacity(0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          '$completedCount/$totalCount',
                          style: TextStyle(
                            color: allDone
                                ? const Color(0xFF4ECDC4)
                                : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            allDone
                                ? '🎉 All habits completed!'
                                : 'Keep going, you\'ve got this!',
                            style: TextStyle(
                              color: allDone
                                  ? const Color(0xFF4ECDC4)
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF4ECDC4),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) =>
                              LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Habit list
                Expanded(
                  child: habits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 64,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No habits yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Go add some habits from the home screen!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: habits.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            final colors = _getGradientColors(index);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: habit.isDone
                                    ? Colors.white.withOpacity(0.04)
                                    : Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: habit.isDone
                                      ? const Color(0xFF4ECDC4).withOpacity(0.4)
                                      : Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _toggleHabit(habit),
                                borderRadius: BorderRadius.circular(18),
                                splashColor:
                                    const Color(0xFF4ECDC4).withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Gradient icon container
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: habit.isDone
                                              ? null
                                              : LinearGradient(
                                                  colors: colors,
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          color: habit.isDone
                                              ? const Color(0xFF4ECDC4)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          habit.isDone
                                              ? Icons.check_rounded
                                              : _getHabitIcon(habit),
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Habit name & status
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              habit.name,
                                              style: TextStyle(
                                                color: habit.isDone
                                                    ? Colors.white
                                                        .withOpacity(0.5)
                                                    : Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                decoration: habit.isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                decorationColor: Colors.white
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              habit.isDone
                                                  ? 'Completed ✓'
                                                  : 'Tap to mark as done',
                                              style: TextStyle(
                                                color: habit.isDone
                                                    ? const Color(0xFF4ECDC4)
                                                    : Colors.white
                                                        .withOpacity(0.35),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Checkbox
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: habit.isDone
                                              ? const Color(0xFF4ECDC4)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: habit.isDone
                                                ? const Color(0xFF4ECDC4)
                                                : Colors.white.withOpacity(0.3),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: habit.isDone
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Mark All as Done button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: GestureDetector(
                    onTapDown: allDone || _isMarkingAll
                        ? null
                        : (_) => _controller.forward(),
                    onTapUp: allDone || _isMarkingAll
                        ? null
                        : (_) async {
                            await _controller.reverse();
                            _markAllDone(habits);
                          },
                    onTapCancel: allDone || _isMarkingAll
                        ? null
                        : () => _controller.reverse(),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: allDone
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF4ECDC4).withOpacity(0.4),
                                    const Color(0xFF2FB5AC).withOpacity(0.4),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF4ECDC4),
                                    Color(0xFF2FB5AC),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: allDone
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4)
                                        .withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isMarkingAll
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      allDone
                                          ? Icons.check_circle_rounded
                                          : Icons.done_all_rounded,
                                      color: Colors.white
                                          .withOpacity(allDone ? 0.6 : 1.0),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      allDone
                                          ? 'All Habits Completed!'
                                          : 'Mark All as Done',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(allDone ? 0.6 : 1.0),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
