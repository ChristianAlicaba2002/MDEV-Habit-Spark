import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/health_log_model.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/health_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

class DashboardTab extends StatelessWidget {
  final String userId;
  final String userName;
  final String userInitial;
  final List<Habit> habits;
  final HabitService habitService;
  final HealthService _healthService = HealthService();
  final StreakService _streakService = StreakService();
  final TextEditingController _searchController = TextEditingController();

  DashboardTab({
    super.key,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habits,
    required this.habitService,
  });

  void _confirmDelete(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text('Delete Habit?', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              habitService.deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: GoogleFonts.outfit(color: AppColors.secondaryLight, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group habits by routine
    final morningHabits = habits.where((h) => h.routine == 'Morning').toList();
    final afternoonHabits = habits.where((h) => h.routine == 'Afternoon').toList();
    final eveningHabits = habits.where((h) => h.routine == 'Evening').toList();
    final otherHabits = habits.where((h) => !['Morning', 'Afternoon', 'Evening'].contains(h.routine)).toList();

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
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "$userName's Activity",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _HeaderIcon(icon: CupertinoIcons.bell, hasNotification: true),
                    const SizedBox(width: 12),
                    _HeaderIcon(
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchBar(controller: _searchController),
            ),
          ),

          // Daily Tasks / Routines (Moved to top)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Tasks', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (morningHabits.isNotEmpty)
                    _RoutineCardWithIcon(
                      title: 'Morning Routine',
                      habits: morningHabits,
                      userId: userId,
                      habitService: habitService,
                      onConfirmDelete: (h) => _confirmDelete(context, h),
                      icon: CupertinoIcons.sun_max_fill,
                      iconColor: const Color(0xFFD4A574),
                      iconBgColor: const Color(0xFF6B5344),
                    ),
                  if (morningHabits.isNotEmpty) const SizedBox(height: 12),
                  if (afternoonHabits.isNotEmpty)
                    _RoutineCardWithIcon(
                      title: 'Afternoon Routine',
                      habits: afternoonHabits,
                      userId: userId,
                      habitService: habitService,
                      onConfirmDelete: (h) => _confirmDelete(context, h),
                      icon: CupertinoIcons.sun_max,
                      iconColor: const Color(0xFFFFD700),
                      iconBgColor: const Color(0xFF8B7500),
                      initiallyExpanded: true,
                    ),
                  if (afternoonHabits.isNotEmpty) const SizedBox(height: 12),
                  if (eveningHabits.isNotEmpty)
                    _RoutineCardWithIcon(
                      title: 'Evening Routine',
                      habits: eveningHabits,
                      userId: userId,
                      habitService: habitService,
                      onConfirmDelete: (h) => _confirmDelete(context, h),
                      icon: CupertinoIcons.moon_stars_fill,
                      iconColor: const Color(0xFF9B7EBD),
                      iconBgColor: const Color(0xFF4A3F5C),
                    ),
                  if (eveningHabits.isNotEmpty) const SizedBox(height: 12),
                  if (otherHabits.isNotEmpty)
                    _RoutineCardWithIcon(
                      title: 'General Habits',
                      habits: otherHabits,
                      userId: userId,
                      habitService: habitService,
                      onConfirmDelete: (h) => _confirmDelete(context, h),
                      icon: CupertinoIcons.arrow_2_circlepath,
                      iconColor: const Color(0xFF7FD8BE),
                      iconBgColor: const Color(0xFF3F6B5C),
                    ),
                ],
              ),
            ),
          ),

          // Daily Activity Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Activity', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _DailyActivityGrid(healthService: _healthService, streakService: _streakService, userId: userId),
                ],
              ),
            ),
          ),

          // Weekly Performance
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: _WeeklyPerformance(healthService: _healthService, userId: userId),
            ),
          ),
          // Recent Activities
          // Removed - using Weekly Performance chart instead

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      ),
    );
  }
}




// --- Sub-widgets ---

class _HeaderIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final bool hasNotification;
  const _HeaderIcon({this.icon, this.child, this.hasNotification = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 20),
          if (child != null) child!,
          if (hasNotification)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(CupertinoIcons.search, color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _DailyActivityGrid extends StatelessWidget {
  final HealthService healthService;
  final StreakService streakService;
  final String userId;

  const _DailyActivityGrid({required this.healthService, required this.streakService, required this.userId});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayEnd = today.add(const Duration(days: 1));
    
    // Last week same period
    final lastWeekStart = today.subtract(const Duration(days: 7));
    final lastWeekEnd = lastWeekStart.add(const Duration(days: 1));

    return Column(
      children: [
        Row(
          children: [
            // Distance Run Card
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: healthService.getActivityMonthlyStats('distance run'),
                  builder: (context, snapshot) {
                    String distanceValue = '0';
                    String distanceUnit = 'km';
                    String distanceTrend = '↑ 0%';
                    Color trendColor = Colors.greenAccent;

                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      distanceValue = (data['total'] as double).toStringAsFixed(1);
                      distanceUnit = data['unit'] ?? 'km';
                    }

                    return _ActivityCardNew(
                      icon: LucideIcons.zap,
                      iconColor: Colors.tealAccent,
                      iconBgColor: Colors.tealAccent.withOpacity(0.2),
                      title: 'Distance Run',
                      value: distanceValue,
                      unit: distanceUnit,
                      subtitle: 'vs last week',
                      trend: distanceTrend,
                      trendColor: trendColor,
                      visual: const _SpeedometerVisual(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Workouts Card
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: StreamBuilder<List<HealthLog>>(
                  stream: healthService.getDailyLogs(today),
                  builder: (context, snapshot) {
                    int workoutCount = 0;
                    String workoutTrend = '↑ 0%';
                    Color trendColor = Colors.greenAccent;

                    if (snapshot.hasData) {
                      // Count unique workout sessions (could be based on type or count)
                      workoutCount = snapshot.data!.length;
                    }

                    return _ActivityCardNew(
                      icon: CupertinoIcons.bolt_fill,
                      iconColor: Colors.purpleAccent,
                      iconBgColor: Colors.purpleAccent.withOpacity(0.2),
                      title: 'Workouts',
                      value: workoutCount.toString(),
                      unit: 'sessions',
                      subtitle: 'vs last week',
                      trend: workoutTrend,
                      trendColor: trendColor,
                      visual: const _MiniBarChart(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Day Streak Card
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: streakService.getStreakStream(userId),
                  builder: (context, snapshot) {
                    int streakDays = 0;
                    String streakTrend = '↓ 0%';
                    Color trendColor = Colors.orangeAccent;

                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      streakDays = data['currentStreak'] ?? 0;
                    }

                    return _ActivityCardNew(
                      icon: CupertinoIcons.flame_fill,
                      iconColor: Colors.orangeAccent,
                      iconBgColor: Colors.orangeAccent.withOpacity(0.2),
                      title: 'Day Streak',
                      value: streakDays.toString(),
                      unit: 'days',
                      subtitle: 'vs last week',
                      trend: streakTrend,
                      trendColor: trendColor,
                      visual: const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 50),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Calories Burned Card
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: healthService.getActivityMonthlyStats('calories burned'),
                  builder: (context, snapshot) {
                    String caloriesValue = '0';
                    String caloriesUnit = 'kcal';
                    String caloriesTrend = '↑ 0%';
                    Color trendColor = Colors.greenAccent;

                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      caloriesValue = (data['total'] as double).toStringAsFixed(0);
                      caloriesUnit = data['unit'] ?? 'kcal';
                    }

                    return _ActivityCardNew(
                      icon: CupertinoIcons.flame,
                      iconColor: Colors.tealAccent,
                      iconBgColor: Colors.tealAccent.withOpacity(0.2),
                      title: 'Calories Burned',
                      value: caloriesValue,
                      unit: caloriesUnit,
                      subtitle: 'vs last week',
                      trend: caloriesTrend,
                      trendColor: trendColor,
                      visual: const _WaveVisual(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final String trend;
  final Color trendColor;
  final Widget visual;

  const _ActivityCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.trend,
    this.trendColor = Colors.white,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                if (trend.isNotEmpty)
                  Text(trend, style: GoogleFonts.outfit(color: trendColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(unit, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: visual,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ActivityCardNew extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final String trend;
  final Color trendColor;
  final Widget visual;

  const _ActivityCardNew({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.trend,
    required this.trendColor,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon, Title, Trend
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: trendColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(trend, style: GoogleFonts.outfit(color: trendColor, fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Value and Visual
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      const SizedBox(height: 1),
                      Text(unit, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 1),
                      Text(subtitle, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 35,
                  height: 35,
                  child: visual,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineSection extends StatefulWidget {
  final String title;
  final List<Habit> habits;
  final String userId;
  final HabitService habitService;
  final Function(Habit) onConfirmDelete;
  final bool initiallyExpanded;

  const _RoutineSection({
    required this.title,
    required this.habits,
    required this.userId,
    required this.habitService,
    required this.onConfirmDelete,
    this.initiallyExpanded = false,
  });

  @override
  State<_RoutineSection> createState() => _RoutineSectionState();
}

class _RoutineSectionState extends State<_RoutineSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.habits.where((h) => h.isDone).length;
    final totalCount = widget.habits.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(_isExpanded ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Text(widget.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (totalCount > 0)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            value: completedCount / totalCount,
                            strokeWidth: 3,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          ),
                        ),
                        Text('$completedCount/$totalCount', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.habits.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.habits.map((habit) => _HabitCheckItem(
                  habit: habit,
                  userId: widget.userId,
                  habitService: widget.habitService,
                  onDelete: () => widget.onConfirmDelete(habit),
                )).toList(),
              ),
            ),
          if (_isExpanded && widget.habits.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('No tasks in this routine', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _HabitCheckItem extends StatelessWidget {
  final Habit habit;
  final String userId;
  final HabitService habitService;
  final VoidCallback onDelete;

  const _HabitCheckItem({required this.habit, required this.userId, required this.habitService, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => habitService.toggleHabit(habit.id, habit.isDone, userId),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orangeAccent, width: 2),
                color: habit.isDone ? Colors.orangeAccent : Colors.transparent,
              ),
              child: habit.isDone ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              style: GoogleFonts.outfit(
                color: habit.isDone ? Colors.white54 : Colors.white,
                fontSize: 16,
                decoration: habit.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.white24, size: 16),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _RoutineCardWithIcon extends StatefulWidget {
  final String title;
  final List<Habit> habits;
  final String userId;
  final HabitService habitService;
  final Function(Habit) onConfirmDelete;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool initiallyExpanded;

  const _RoutineCardWithIcon({
    required this.title,
    required this.habits,
    required this.userId,
    required this.habitService,
    required this.onConfirmDelete,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.initiallyExpanded = false,
  });

  @override
  State<_RoutineCardWithIcon> createState() => _RoutineCardWithIconState();
}

class _RoutineCardWithIconState extends State<_RoutineCardWithIcon> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.habits.where((h) => h.isDone).length;
    final totalCount = widget.habits.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon with background
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Title and completion
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${(progress * 100).toStringAsFixed(0)}% completed', style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Completion count and chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$completedCount/$totalCount', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Icon(_isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, color: Colors.white, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.habits.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.habits.map((habit) => _HabitCheckItem(
                  habit: habit,
                  userId: widget.userId,
                  habitService: widget.habitService,
                  onDelete: () => widget.onConfirmDelete(habit),
                )).toList(),
              ),
            ),
          if (_isExpanded && widget.habits.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('No tasks in this routine', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _WeeklyPerformance extends StatelessWidget {
  final HealthService healthService;
  final String userId;
  const _WeeklyPerformance({required this.healthService, required this.userId});

  @override
  Widget build(BuildContext context) {
    final weekData = [0.3, 1.0, 0.4, 0.2, 0.6, 0.3, 0.1]; // Mon to Sun
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Text('Weekly Performance', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chart bars
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final height = weekData[index];
                    final isTuesday = index == 1;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 28,
                          height: 120 * height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isTuesday
                                  ? [Colors.greenAccent, Colors.greenAccent.withOpacity(0.6)]
                                  : [Colors.tealAccent.withOpacity(0.8), Colors.tealAccent.withOpacity(0.3)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          days[index],
                          style: GoogleFonts.outfit(
                            color: isTuesday ? Colors.greenAccent : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Avg', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('0.47', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Peak', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Tue', style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Total', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('3.3', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final String title;
  final String detail;
  final IconData icon;
  final Color iconColor;

  const _RecentActivityItem({required this.title, required this.detail, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$title ', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  TextSpan(text: '($detail)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedometerVisual extends StatelessWidget {
  const _SpeedometerVisual();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 25,
      child: CustomPaint(
        painter: _SpeedometerPainter(),
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height * 2), 3.14, 3.14, false, paint);
    paint.color = Colors.tealAccent;
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height * 2), 3.14, 2.1, false, paint);
    
    final center = Offset(size.width / 2, size.height);
    canvas.drawLine(center, center + Offset.fromDirection(-0.8, 15), Paint()..color = Colors.tealAccent..strokeWidth = 2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [0.3, 0.6, 1.0, 0.4, 0.7].map((h) => Container(
        width: 4,
        height: 20 * h,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(color: h == 1.0 ? Colors.orange : Colors.white24, borderRadius: BorderRadius.circular(1)),
      )).toList(),
    );
  }
}

class _WaveVisual extends StatelessWidget {
  const _WaveVisual();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 20,
      child: CustomPaint(
        painter: _WavePainter(),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.tealAccent..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, 0);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
