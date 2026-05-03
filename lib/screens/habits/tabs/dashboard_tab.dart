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
              child: Padding(
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
                            const Text(
                              "5-Day Streak 🔥",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            // Mini completion bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: 5 / 7,
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

            // ── Stats Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    _HealthStatCard(
                      title: 'Step to wall',
                      value: '5,400',
                      unit: 'steps',
                      progress: 0.7,
                      badge: 'Good',
                      icon: CupertinoIcons.paw,
                      showAddButton: true,
                    ),
                    SizedBox(width: 16),
                    _HealthStatCard(
                      title: 'Cal burnt',
                      value: '312',
                      unit: 'KCAL',
                      progress: 0.4,
                      badge: 'Average',
                      icon: CupertinoIcons.flame_fill,
                      showAddButton: true,
                    ),
                    SizedBox(width: 16),
                    _HealthStatCard(
                      title: 'Kilometers',
                      value: '4.2',
                      unit: 'KM',
                      progress: 0.8,
                      badge: 'Good',
                      icon: CupertinoIcons.location_fill,
                      showAddButton: false,
                    ),
                  ],
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

class _HealthStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double progress;
  final String badge;
  final IconData icon;
  final bool showAddButton;

  const _HealthStatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    required this.badge,
    required this.icon,
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
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
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
