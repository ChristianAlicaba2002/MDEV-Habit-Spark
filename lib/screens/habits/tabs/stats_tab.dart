import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/health_service.dart';
import 'package:habit_spark/services/category_service.dart';
import 'package:habit_spark/services/session_timer_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

class StatsTab extends StatefulWidget {
  final String userId;
  final List<Habit> habits;
  final StreakService streakService;

  const StatsTab({
    super.key,
    required this.userId,
    required this.habits,
    required this.streakService,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String _selectedTimeFrame = 'Week';
  String _selectedTrendsCategory = 'Fitness';
  final HealthService _healthService = HealthService();
  final CategoryService _categoryService = CategoryService();
  final SessionTimerService _timerService = SessionTimerService();

  void _showCategoryPicker(List<CategoryModel> categories) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Select Trends Category', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        message: const Text('Choose which category trends you want to see.'),
        actions: categories.map((cat) => CupertinoActionSheetAction(
          onPressed: () {
            setState(() => _selectedTrendsCategory = cat.name);
            Navigator.pop(context);
          },
          child: Text(cat.name, style: GoogleFonts.outfit(color: cat.color)),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 220.0; // Increased to 220 to prevent overflow

    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategoriesStream(widget.userId),
      builder: (context, catSnapshot) {
        final categories = catSnapshot.data ?? [];
        
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
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(DateTime.now()),
                                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Activity Stats",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Time Selector
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: ['Week', 'Month', 'Year'].map((time) {
                                bool isSelected = _selectedTimeFrame == time;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedTimeFrame = time),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          time,
                                          style: GoogleFonts.outfit(
                                            color: isSelected ? Colors.white : Colors.white60,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      // Trends
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: GestureDetector(
                            onLongPress: () => _showCategoryPicker(categories),
                            child: _DynamicCategoryTrendsCard(
                              category: _selectedTrendsCategory,
                              habits: widget.habits,
                              categories: categories,
                            ),
                          ),
                        ),
                      ),

                      // Active Minutes & Consistency Row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _SessionTimerCard(timerService: _timerService, height: cardHeight)),
                              const SizedBox(width: 16),
                              Expanded(child: _RealHabitConsistencyCard(habits: widget.habits, height: cardHeight)),
                            ],
                          ),
                        ),
                      ),

                      // Highest Streak & PRs Row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _HighestStreakCard(streakService: widget.streakService, userId: widget.userId, height: cardHeight)),
                              const SizedBox(width: 16),
                              Expanded(child: _RealPersonalRecordsCard(healthService: _healthService, height: cardHeight)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DynamicCategoryTrendsCard extends StatelessWidget {
  final String category;
  final List<Habit> habits;
  final List<CategoryModel> categories;
  const _DynamicCategoryTrendsCard({required this.category, required this.habits, required this.categories});

  @override
  Widget build(BuildContext context) {
    final categoryHabits = habits.where((h) => h.category == category).toList();
    final catInfo = categories.firstWhere((c) => c.name == category, orElse: () => CategoryModel(id: '', name: 'General', iconCode: '58713', colorValue: 0xFFFFC107, userId: ''));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$category Trends", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(CupertinoIcons.chevron_up, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          if (categoryHabits.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("No tasks in $category", style: GoogleFonts.outfit(color: Colors.white24, fontSize: 13))))
          else
            ...categoryHabits.map((h) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _HabitTrendBar(habit: h, color: catInfo.color))),
        ],
      ),
    );
  }
}

class _HabitTrendBar extends StatelessWidget {
  final Habit habit;
  final Color color;
  const _HabitTrendBar({required this.habit, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = habit.isDone ? 1.0 : 0.1;
    return Row(
      children: [
        SizedBox(width: 70, child: Text(habit.name, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(habit.isDone ? "100%" : "0%", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _SessionTimerCard extends StatelessWidget {
  final SessionTimerService timerService;
  final double height;
  const _SessionTimerCard({required this.timerService, required this.height});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timerService.sessionStream,
      initialData: timerService.currentSeconds,
      builder: (context, snapshot) {
        final seconds = snapshot.data ?? 0;
        final progress = (seconds / 86400).clamp(0.0, 1.0);
        int h = seconds ~/ 3600;
        int m = (seconds % 3600) ~/ 60;
        int s = seconds % 60;

        return Container(
          height: height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Active Minutes", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90, 
                    height: 90, 
                    child: CircularProgressIndicator(
                      value: progress, 
                      strokeWidth: 8, 
                      backgroundColor: Colors.white.withOpacity(0.05), 
                      valueColor: const AlwaysStoppedAnimation(Colors.orange),
                      strokeCap: StrokeCap.round,
                    )
                  ),
                  Text("${h*60 + m}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Text("Session: ${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}", style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

class _RealHabitConsistencyCard extends StatelessWidget {
  final List<Habit> habits;
  final double height;
  const _RealHabitConsistencyCard({required this.habits, required this.height});

  @override
  Widget build(BuildContext context) {
    final displayHabits = habits.take(6).toList();
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Consistency", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (displayHabits.isEmpty)
            const Expanded(child: Center(child: Text("No habits", style: TextStyle(color: Colors.white24, fontSize: 12))))
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: displayHabits.map((h) => _ConsistencyItem(
                  icon: h.icon != null ? IconData(int.parse(h.icon!), fontFamily: 'MaterialIcons') : Icons.check,
                  progress: h.isDone ? 1.0 : 0.0,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsistencyItem extends StatelessWidget {
  final IconData icon;
  final double progress;
  const _ConsistencyItem({required this.icon, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation(Colors.orange),
                strokeCap: StrokeCap.round,
              ),
            ),
            Icon(icon, color: Colors.orange.withOpacity(0.8), size: 20),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${(progress * 100).toInt()}%", 
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}

class _HighestStreakCard extends StatelessWidget {
  final StreakService streakService;
  final String userId;
  final double height;
  const _HighestStreakCard({required this.streakService, required this.userId, required this.height});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: streakService.getStreakStream(userId),
      builder: (context, snapshot) {
        final longestStreak = snapshot.data?['longestStreak'] ?? 0;
        final currentStreak = snapshot.data?['currentStreak'] ?? 0;

        return Container(
          height: height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Highest Streak", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      "$longestStreak", 
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                    ),
                    Text("DAYS", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              Center(child: Text("Current: $currentStreak days", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11))),
            ],
          ),
        );
      }
    );
  }
}

class _RealPersonalRecordsCard extends StatelessWidget {
  final HealthService healthService;
  final double height;
  const _RealPersonalRecordsCard({required this.healthService, required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Records", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          _PRStreamItem(label: "Longest Run", type: "running", unit: "km", healthService: healthService),
          const SizedBox(height: 16),
          _PRStreamItem(label: "Max Lift", type: "lifting", unit: "kg", healthService: healthService),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PRStreamItem extends StatelessWidget {
  final String label;
  final String type;
  final String unit;
  final HealthService healthService;
  const _PRStreamItem({required this.label, required this.type, required this.unit, required this.healthService});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: healthService.getActivityMonthlyStats(type),
      builder: (context, snapshot) {
        final total = snapshot.data?['total'] ?? 0.0;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
          Text("${total.toInt()} $unit", style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        ]);
      },
    );
  }
}
