import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';
import 'package:habit_spark/screens/misc/tasks_list_page.dart';
import 'package:habit_spark/screens/misc/stats_details_page.dart';
import 'package:habit_spark/models/task_model.dart';
import 'package:habit_spark/services/task_service.dart';
import 'package:habit_spark/services/health_service.dart';
import 'package:shimmer/shimmer.dart';

class DashboardTab extends StatelessWidget {
  final String userId;
  final String userName;
  final String userInitial;
  final List<Habit> habits;
  final int completedCount;
  final int totalCount;
  final double progress;
  final Animation<double> heroFadeAnim;
  final Animation<double> ringProgressAnim;
  final NotificationService notificationService;
  final StreakService streakService;
  final AuthService authService;
  final TextEditingController searchController;
  final VoidCallback onAddHabit;
  final VoidCallback onProfileTap;
  final TaskService _taskService = TaskService();
  final HealthService _healthService = HealthService();

  DashboardTab({
    super.key,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habits,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.heroFadeAnim,
    required this.ringProgressAnim,
    required this.notificationService,
    required this.streakService,
    required this.authService,
    required this.searchController,
    required this.onAddHabit,
    required this.onProfileTap,
  });

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
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Custom App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w300,
                                    height: 1.2,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Welcome, '),
                                    TextSpan(
                                      text: userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: '!'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Today is ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                        const SizedBox(width: 16),
                        Stack(
                          children: [
                            RoundIconButton(
                              icon: CupertinoIcons.bell,
                              onTap: () {},
                              outlined: true,
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                     filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                     child: Container(
                       height: 60,
                       padding: const EdgeInsets.symmetric(horizontal: 20),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.12),
                         borderRadius: BorderRadius.circular(35),
                         border: Border.all(color: Colors.white.withOpacity(0.1)),
                       ),
                       child: Row(
                         children: [
                           Icon(CupertinoIcons.search, color: Colors.white.withOpacity(0.6)),
                           const SizedBox(width: 12),
                           Expanded(
                             child: TextField(
                               controller: searchController,
                               style: const TextStyle(color: Colors.white),
                               decoration: InputDecoration(
                                 hintText: 'Search...',
                                 hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                 border: InputBorder.none,
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                  ),
                ),
              ),
            ),

            // ── Streak Card
            SliverToBoxAdapter(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: streakService.getStreakStream(userId),
                builder: (context, snapshot) {
                  final streakData = snapshot.data;
                  final currentStreak = streakData?['currentStreak'] ?? 0;
                  
                  // For the progress bar, use 7-day milestones
                  final progress = currentStreak == 0 ? 0.0 : (currentStreak % 7 == 0 ? 1.0 : (currentStreak % 7) / 7);
                  final streakText = currentStreak == 0 ? "Start your streak! 🔥" : "$currentStreak-Day Streak 🔥";

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  streakText,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                // Mini completion bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                                    minHeight: 6,
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
              ),
            ),

            _DashboardSectionHeader(
              title: "Today's stats",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsDetailsPage()),
                );
              },
            ),

            // ── Stats Horizontal List (Dynamic Pinned Activities)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: StreamBuilder<List<String>>(
                  stream: _healthService.getPinnedActivitiesStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CupertinoActivityIndicator(color: Colors.orangeAccent));
                    }
                    
                    final pinnedTypes = snapshot.data ?? [];
                    
                    if (pinnedTypes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: Text(
                            "Pin activities from 'View more' to see them here!",
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: pinnedTypes.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final type = pinnedTypes[index];
                        return _PinnedStatCard(
                          type: type,
                          healthService: _healthService,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // ── Daily Checklist Header
            _DashboardSectionHeader(
              title: "Daily Tasks",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TasksListPage(title: 'Daily Tasks', userId: userId),
                  ),
                );
              },
            ),

            // ── Daily Checklist Items (Dynamic Stream)
            StreamBuilder<List<TaskModel>>(
              stream: _taskService.getTasksStream(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text("Couldn't load tasks", style: TextStyle(color: Colors.white54))),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.05),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: List.generate(3, (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                          )),
                        ),
                      ),
                    ),
                  );
                }
                
                final tasks = snapshot.data?.where((t) => t.isRecent).toList() ?? [];
                
                if (tasks.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text("No recent tasks. Go to 'View more' to add some!", style: TextStyle(color: Colors.white54))),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DailyTaskItem(
                            title: task.title, 
                            isCompleted: task.isCompleted,
                            onToggle: () => _taskService.toggleTask(task.id, task.isCompleted),
                          ),
                        );
                      },
                      childCount: tasks.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }
}



class _DailyTaskItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _DailyTaskItem({
    required this.title, 
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.white.withOpacity(0.5) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DashboardSectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Text(
                'View more',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedStatCard extends StatelessWidget {
  final String type;
  final HealthService healthService;

  const _PinnedStatCard({required this.type, required this.healthService});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = start.add(const Duration(days: 1));

    return StreamBuilder<double>(
      stream: healthService.getTypeTotalForPeriod(type, start, end),
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0.0;
        final unit = _getDefaultUnit(type);
        final color = _getThemeColor(type);
        final icon = _getThemeIcon(type);
        final formattedValue = _formatTotalValue(value, unit);
        
        return _HealthStatCard(
          title: type.toUpperCase(),
          value: formattedValue,
          unit: _getSmartUnit(type, value),
          progress: (value / 10000).clamp(0.0, 1.0), // Simplified goal
          badge: value > 0 ? 'Active' : 'Start',
          icon: icon,
          color: color,
        );
      },
    );
  }

  // Helper methods duplicated from StatsDetailsPage for consistency
  String _getSmartUnit(String type, double value) {
    final t = type.toLowerCase();
    if (t.contains('step')) return 'steps';
    if (t.contains('walk') || t.contains('run') || t.contains('bike') || t.contains('cycle') || t.contains('distance')) return 'km';
    if (t.contains('eat') || t.contains('water') || t.contains('drink')) return 'ml';
    double seconds = value * 3600;
    if (seconds < 60) return 'secs';
    if (seconds < 3600) return 'mins';
    return 'hrs';
  }

  String _formatTotalValue(double value, String unit) {
    if (unit.toLowerCase() == 'hrs' || unit.toLowerCase() == 'mins' || unit.toLowerCase() == 'secs') {
      int totalSeconds = unit.toLowerCase() == 'hrs' ? (value * 3600).round() : (unit.toLowerCase() == 'mins' ? (value * 60).round() : value.round());
      if (totalSeconds < 60) return "$totalSeconds";
      int m = totalSeconds ~/ 60;
      int s = totalSeconds % 60;
      if (m < 60) return "$m:${s.toString().padLeft(2, '0')}";
      int h = m ~/ 60;
      int remM = m % 60;
      return "$h:${remM.toString().padLeft(2, '0')}";
    }
    return value == 0 ? "0" : (value < 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1));
  }

  Color _getThemeColor(String type) {
    switch (type.toLowerCase()) {
      case 'steps': return Colors.tealAccent;
      case 'calories': return Colors.orangeAccent;
      case 'distance': return Colors.blueAccent;
      case 'sleep': return Colors.purpleAccent;
      case 'gym': return Colors.redAccent;
      case 'yoga': return Colors.pinkAccent;
      case 'water': return Colors.cyanAccent;
      default: return Colors.orangeAccent;
    }
  }

  IconData _getThemeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'steps': return Icons.directions_walk;
      case 'calories': return CupertinoIcons.flame;
      case 'distance': return CupertinoIcons.map;
      case 'sleep': return CupertinoIcons.moon;
      case 'gym': return Icons.fitness_center;
      case 'yoga': return Icons.self_improvement;
      case 'water': return Icons.local_drink;
      default: return Icons.bolt;
    }
  }

  String _getDefaultUnit(String type) {
    switch (type.toLowerCase()) {
      case 'steps': return 'steps';
      case 'calories': return 'kcal';
      case 'distance': return 'km';
      case 'sleep': return 'hrs';
      default: return 'unit';
    }
  }
}

class _HealthStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double progress;
  final String badge;
  final IconData icon;
  final Color color;
  final bool showAddButton;

  const _HealthStatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    required this.badge,
    required this.icon,
    required this.color,
    this.showAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D3D3D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
          if (showAddButton)
            Positioned(
              right: -5,
              top: -5,
              child: GestureDetector(
                onTap: () {}, // Increment progress action
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
