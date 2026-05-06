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
import 'package:habit_spark/widgets/skeleton_loaders.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatefulWidget {
  final String userId;
  final String userName;
  final String userInitial;
  final List<Habit> habits;
  final HabitService habitService;

  const DashboardTab({
    super.key,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habits,
    required this.habitService,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final HealthService _healthService = HealthService();
  final StreakService _streakService = StreakService();
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isRefreshing = false);
  }

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
              widget.habitService.deleteHabit(habit.id);
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
    final habits = widget.habits;
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
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.warning,
          backgroundColor: const Color(0xFF1E2E2E),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: _isRefreshing 
              ? [const SliverDashboardSkeleton()]
              : [
              // Header
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${widget.userName}'s Activity",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _HeaderIcon(icon: CupertinoIcons.bell, hasNotification: true),
                    const SizedBox(width: 12),
                    _HeaderIcon(
                      child: Text(
                        widget.userInitial,
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
                      userId: widget.userId,
                      habitService: widget.habitService,
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
                      userId: widget.userId,
                      habitService: widget.habitService,
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
                      userId: widget.userId,
                      habitService: widget.habitService,
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
                      userId: widget.userId,
                      habitService: widget.habitService,
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
                  _DailyActivityGrid(healthService: _healthService, streakService: _streakService, userId: widget.userId),
                ],
              ),
            ),
          ),

          // Weekly Performance
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: _WeeklyPerformance(healthService: _healthService, userId: widget.userId),
            ),
          ),

          // Recent Activity Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: _RecentActivitySection(healthService: _healthService),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
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

class _DailyActivityGrid extends StatefulWidget {
  final HealthService healthService;
  final StreakService streakService;
  final String userId;

  const _DailyActivityGrid({required this.healthService, required this.streakService, required this.userId});

  @override
  State<_DailyActivityGrid> createState() => _DailyActivityGridState();
}

class _DailyActivityGridState extends State<_DailyActivityGrid> with TickerProviderStateMixin {
  // Track which activity is displayed in each position
  late Map<int, String> displayedActivities;
  
  // Default activities for each position
  final Map<int, String> defaultActivities = {
    0: 'distance run',
    1: 'completed tasks',
    2: 'day streak',
    3: 'calories burned',
  };

  bool isModifyMode = false;
  int? selectedCardPosition; // Track which card is being modified
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    displayedActivities = Map.from(defaultActivities);
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _loadSavedActivities();
  }

  Future<void> _loadSavedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < 4; i++) {
        final saved = prefs.getString('activity_position_$i');
        if (saved != null) {
          displayedActivities[i] = saved;
        }
      }
    });
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 4; i++) {
      await prefs.setString('activity_position_$i', displayedActivities[i]!);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _startShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        if (isModifyMode) {
          _startShakeAnimation();
        }
      });
    });
  }

  void _toggleModifyMode() {
    setState(() {
      if (isModifyMode) {
        isModifyMode = false;
        selectedCardPosition = null;
        _shakeController.stop();
      } else {
        isModifyMode = true;
        _startShakeAnimation();
      }
    });
  }

  void _showActivitySelector(BuildContext context, int position) {
    setState(() {
      selectedCardPosition = position;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StreamBuilder<List<Map<String, String>>>(
        stream: widget.healthService.getAllActivityTypes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final activities = snapshot.data!;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select Activity',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final activityType = activity['type'] ?? '';
                    final isSelected = displayedActivities[position] == activityType;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          displayedActivities[position] = activityType;
                          selectedCardPosition = null;
                        });
                        _saveActivities();
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.greenAccent.withOpacity(0.2)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.greenAccent
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activityType.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unit: ${activity['unit'] ?? 'N/A'}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.greenAccent, size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: Colors.white.withOpacity(0.1),
                    onPressed: () {
                      setState(() {
                        selectedCardPosition = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white70)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      setState(() {
        selectedCardPosition = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _toggleModifyMode,
      onTap: isModifyMode ? _toggleModifyMode : null,
      child: Column(
        children: [
          // Activity Grid
          Column(
            children: [
              Row(
                children: [
                  // Position 0 - Top Left
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _ActivityCardWithModify(
                        position: 0,
                        activityType: displayedActivities[0]!,
                        healthService: widget.healthService,
                        streakService: widget.streakService,
                        userId: widget.userId,
                        isModifyMode: isModifyMode,
                        isSelected: selectedCardPosition == 0,
                        shakeController: _shakeController,
                        onModifyPressed: () => _showActivitySelector(context, 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Position 1 - Top Right
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _ActivityCardWithModify(
                        position: 1,
                        activityType: displayedActivities[1]!,
                        healthService: widget.healthService,
                        streakService: widget.streakService,
                        userId: widget.userId,
                        isModifyMode: isModifyMode,
                        isSelected: selectedCardPosition == 1,
                        shakeController: _shakeController,
                        onModifyPressed: () => _showActivitySelector(context, 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Position 2 - Bottom Left
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _ActivityCardWithModify(
                        position: 2,
                        activityType: displayedActivities[2]!,
                        healthService: widget.healthService,
                        streakService: widget.streakService,
                        userId: widget.userId,
                        isModifyMode: isModifyMode,
                        isSelected: selectedCardPosition == 2,
                        shakeController: _shakeController,
                        onModifyPressed: () => _showActivitySelector(context, 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Position 3 - Bottom Right
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _ActivityCardWithModify(
                        position: 3,
                        activityType: displayedActivities[3]!,
                        healthService: widget.healthService,
                        streakService: widget.streakService,
                        userId: widget.userId,
                        isModifyMode: isModifyMode,
                        isSelected: selectedCardPosition == 3,
                        shakeController: _shakeController,
                        onModifyPressed: () => _showActivitySelector(context, 3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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

// Wrapper widget that handles modify mode with shake and blur effects
class _ActivityCardWithModify extends StatelessWidget {
  final int position;
  final String activityType;
  final HealthService healthService;
  final StreakService streakService;
  final String userId;
  final bool isModifyMode;
  final bool isSelected;
  final AnimationController shakeController;
  final VoidCallback onModifyPressed;

  const _ActivityCardWithModify({
    required this.position,
    required this.activityType,
    required this.healthService,
    required this.streakService,
    required this.userId,
    required this.isModifyMode,
    required this.isSelected,
    required this.shakeController,
    required this.onModifyPressed,
  });

  IconData _getIconForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'distance run':
        return LucideIcons.zap;
      case 'completed tasks':
        return CupertinoIcons.checkmark_circle_fill;
      case 'day streak':
        return CupertinoIcons.flame_fill;
      case 'calories burned':
        return CupertinoIcons.flame;
      default:
        return CupertinoIcons.chart_bar;
    }
  }

  Color _getColorForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'distance run':
        return Colors.tealAccent;
      case 'completed tasks':
        return Colors.greenAccent;
      case 'day streak':
        return Colors.orangeAccent;
      case 'calories burned':
        return Colors.tealAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Widget _getVisualForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'distance run':
        return const _SpeedometerVisual();
      case 'completed tasks':
        return const _MiniBarChart();
      case 'day streak':
        return const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 50);
      case 'calories burned':
        return const _WaveVisual();
      default:
        return const Icon(CupertinoIcons.chart_bar, color: Colors.white, size: 40);
    }
  }

  String _getCategoryForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'day streak':
        return 'Consistency';
      case 'completed tasks':
        return 'Productivity';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final color = _getColorForActivity(activityType);

    return AnimatedBuilder(
      animation: shakeController,
      builder: (context, child) {
        // iOS-style shake: small offset that alternates
        final shakeOffset = isModifyMode ? (shakeController.value - 0.5) * 3 : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, shakeOffset * 0.3),
          child: Stack(
            children: [
              // Main card
              StreamBuilder<dynamic>(
                stream: _getStreamForActivity(activityType),
                builder: (context, snapshot) {
                  String value = '0';
                  String unit = '';
                  String title = activityType;
                  String category = '';

                  if (snapshot.hasData) {
                    if (activityType.toLowerCase() == 'day streak') {
                      final data = snapshot.data as Map<String, dynamic>;
                      value = (data['currentStreak'] ?? 0).toString();
                      unit = 'days';
                      category = _getCategoryForActivity(activityType);
                    } else if (activityType.toLowerCase() == 'completed tasks') {
                      final logs = snapshot.data as List<HealthLog>;
                      value = logs
                          .where((log) => log.type.toLowerCase() == 'completed tasks')
                          .length
                          .toString();
                      unit = 'tasks';
                      category = _getCategoryForActivity(activityType);
                    } else {
                      final data = snapshot.data as Map<String, dynamic>;
                      value = (data['total'] as double).toStringAsFixed(1);
                      unit = data['unit'] ?? '';
                      // Get category from the data map
                      category = data['category'] ?? '';
                    }
                  }

                  // Capitalize the title (first letter uppercase, rest lowercase)
                  final capitalizedTitle = title.isEmpty 
                      ? title 
                      : title[0].toUpperCase() + title.substring(1).toLowerCase();

                  return _ActivityCardNew(
                    icon: _getIconForActivity(activityType),
                    iconColor: color,
                    iconBgColor: color.withOpacity(0.2),
                    title: capitalizedTitle,
                    value: value,
                    unit: unit,
                    subtitle: category.isNotEmpty ? category : capitalizedTitle,
                    trend: '↑ 0%',
                    trendColor: Colors.greenAccent,
                    visual: _getVisualForActivity(activityType),
                  );
                },
              ),
              // Blur overlay when card is selected for modification
              if (isModifyMode && isSelected)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              // Modify button - centered on card
              if (isModifyMode)
                Positioned.fill(
                  child: Center(
                    child: GestureDetector(
                      onTap: onModifyPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          'Modify',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Stream<dynamic> _getStreamForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'day streak':
        return streakService.getStreakStream(userId);
      case 'completed tasks':
        return healthService.getDailyLogs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
      default:
        return healthService.getActivityMonthlyStats(type);
    }
  }
}

// Old wrapper widget that handles long-press and displays the appropriate activity
class _ActivityCardWrapper extends StatelessWidget {
  final int position;
  final String activityType;
  final HealthService healthService;
  final StreakService streakService;
  final String userId;
  final VoidCallback onLongPress;

  const _ActivityCardWrapper({
    required this.position,
    required this.activityType,
    required this.healthService,
    required this.streakService,
    required this.userId,
    required this.onLongPress,
  });

  IconData _getIconForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'distance run':
        return LucideIcons.zap;
      case 'completed tasks':
        return CupertinoIcons.checkmark_circle_fill;
      case 'day streak':
        return CupertinoIcons.flame_fill;
      case 'calories burned':
        return CupertinoIcons.flame;
      default:
        return CupertinoIcons.chart_bar;
    }
  }

  Color _getColorForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'distance run':
        return Colors.tealAccent;
      case 'completed tasks':
        return Colors.greenAccent;
      case 'day streak':
        return Colors.orangeAccent;
      case 'calories burned':
        return Colors.tealAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Widget _getVisualForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'distance run':
        return const _SpeedometerVisual();
      case 'completed tasks':
        return const _MiniBarChart();
      case 'day streak':
        return const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 50);
      case 'calories burned':
        return const _WaveVisual();
      default:
        return const Icon(CupertinoIcons.chart_bar, color: Colors.white, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final color = _getColorForActivity(activityType);

    return GestureDetector(
      onLongPress: onLongPress,
      child: StreamBuilder<dynamic>(
        stream: _getStreamForActivity(activityType),
        builder: (context, snapshot) {
          String value = '0';
          String unit = '';
          String title = activityType;

          if (snapshot.hasData) {
            if (activityType.toLowerCase() == 'day streak') {
              final data = snapshot.data as Map<String, dynamic>;
              value = (data['currentStreak'] ?? 0).toString();
              unit = 'days';
            } else if (activityType.toLowerCase() == 'completed tasks') {
              final logs = snapshot.data as List<HealthLog>;
              value = logs
                  .where((log) => log.type.toLowerCase() == 'completed tasks')
                  .length
                  .toString();
              unit = 'tasks';
            } else {
              final data = snapshot.data as Map<String, dynamic>;
              value = (data['total'] as double).toStringAsFixed(1);
              unit = data['unit'] ?? '';
            }
          }

          return _ActivityCardNew(
            icon: _getIconForActivity(activityType),
            iconColor: color,
            iconBgColor: color.withOpacity(0.2),
            title: title,
            value: value,
            unit: unit,
            subtitle: 'vs last week',
            trend: '↑ 0%',
            trendColor: Colors.greenAccent,
            visual: _getVisualForActivity(activityType),
          );
        },
      ),
    );
  }

  Stream<dynamic> _getStreamForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'day streak':
        return streakService.getStreakStream(userId);
      case 'completed tasks':
        return healthService.getDailyLogs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
      default:
        return healthService.getActivityMonthlyStats(type);
    }
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon with background
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
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
                        Text('${(progress * 100).toStringAsFixed(0)}% completed', style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Completion count and chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$completedCount/$totalCount', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Icon(_isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, color: Colors.white38, size: 16),
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
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return StreamBuilder<Map<int, double>>(
      stream: healthService.getWeeklyActivitySummary(),
      builder: (context, snapshot) {
        Map<int, double> weekData = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
        String peakDay = 'Mon';
        double avgValue = 0;
        double totalValue = 0;

        if (snapshot.hasData) {
          weekData = snapshot.data!;
          
          // Calculate peak day
          int peakIndex = 0;
          double maxValue = 0;
          weekData.forEach((index, value) {
            if (value > maxValue) {
              maxValue = value;
              peakIndex = index;
            }
          });
          peakDay = days[peakIndex];
          
          // Calculate average and total
          final values = weekData.values.toList();
          totalValue = values.fold(0, (sum, val) => sum + val);
          avgValue = values.isNotEmpty ? totalValue / values.length : 0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        final height = weekData[index] ?? 0;
                        final isPeakDay = days[index] == peakDay;
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
                                  colors: isPeakDay
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
                                color: isPeakDay ? Colors.greenAccent : Colors.white70,
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
                  // Stats - Labels on the left
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Avg', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(avgValue.toStringAsFixed(2), style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Peak', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(peakDay, style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(totalValue.toStringAsFixed(2), style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

class _RecentActivitySection extends StatelessWidget {
  final HealthService healthService;
  const _RecentActivitySection({required this.healthService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View All',
              style: GoogleFonts.outfit(
                color: AppColors.warning,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<HealthLog>>(
          stream: healthService.getRecentLogsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.warning));
            }
            final logs = snapshot.data ?? [];
            if (logs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Icon(CupertinoIcons.square_list, color: Colors.white24, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activities found',
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: logs.map((log) => _ActivityLogItem(log: log)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActivityLogItem extends StatelessWidget {
  final HealthLog log;
  const _ActivityLogItem({required this.log});

  IconData _getIcon() {
    final type = log.type.toLowerCase();
    if (type.contains('steps')) return LucideIcons.footprints;
    if (type.contains('calor')) return LucideIcons.flame;
    if (type.contains('dist')) return LucideIcons.map_pin;
    if (type.contains('workout')) return LucideIcons.dumbbell;
    if (type.contains('sleep')) return LucideIcons.moon;
    if (type.contains('drink') || type.contains('water')) return LucideIcons.droplets;
    return LucideIcons.activity;
  }

  Color _getColor() {
    final type = log.type.toLowerCase();
    if (type.contains('steps')) return Colors.orangeAccent;
    if (type.contains('calor')) return Colors.redAccent;
    if (type.contains('dist')) return Colors.blueAccent;
    if (type.contains('workout')) return Colors.greenAccent;
    if (type.contains('sleep')) return Colors.purpleAccent;
    if (type.contains('drink') || type.contains('water')) return Colors.cyanAccent;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final timeStr = DateFormat('h:mm a').format(log.timestamp);
    final dateStr = DateFormat('MMM d').format(log.timestamp);
    final isToday = DateTime.now().day == log.timestamp.day && 
                   DateTime.now().month == log.timestamp.month;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.type.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.value.toStringAsFixed(1)} ${log.unit}',
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isToday ? 'Today' : dateStr,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                timeStr,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
