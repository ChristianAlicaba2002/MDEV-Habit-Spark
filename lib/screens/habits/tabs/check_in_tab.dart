import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

class CheckInTab extends StatelessWidget {
  final List<Habit> habits;
  final String userId;
  final String userName;
  final String userInitial;
  final HabitService habitService;

  const CheckInTab({
    super.key,
    required this.habits,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habitService,
  });

  @override
  Widget build(BuildContext context) {
    // Group habits by routine
    final morningHabits = habits.where((h) => h.routine == 'Morning').toList();
    
    return Container(
      color: const Color(0xFF162626),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Habits",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _HeaderIcon(icon: CupertinoIcons.bell, hasNotification: true),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Daily Tasks (Routines)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Tasks', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _RoutineTaskCard(title: 'Morning Routine', habits: morningHabits),
                      ],
                    ),
                  ),
                ),

                // My Active Habits
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Active Habits', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 145,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _CircularHabitCard(
                                title: 'Hydration',
                                value: '4',
                                total: '8',
                                unit: 'glasses',
                                icon: CupertinoIcons.drop_fill,
                                color: Colors.cyanAccent,
                                progress: 0.5,
                              ),
                              const SizedBox(width: 12),
                              _CircularHabitCard(
                                title: 'Reading',
                                value: '1',
                                total: '2',
                                unit: 'chapters',
                                icon: CupertinoIcons.book_fill,
                                color: Colors.orangeAccent,
                                progress: 0.5,
                              ),
                              const SizedBox(width: 12),
                              _CircularHabitCard(
                                title: 'Meditation',
                                value: '15m',
                                total: '',
                                unit: 'done',
                                icon: CupertinoIcons.person_fill,
                                color: Colors.deepPurpleAccent,
                                progress: 0.75,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Categories (Horizontal Grid)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                    child: Row(
                      children: const [
                        Expanded(child: _SmallCategoryCard(title: 'Fitness', icon: Icons.fitness_center, color: Colors.orangeAccent)),
                        SizedBox(width: 12),
                        Expanded(child: _SmallCategoryCard(title: 'Productivity', icon: Icons.work_outline, color: Colors.blueAccent)),
                        SizedBox(width: 12),
                        Expanded(child: _SmallCategoryCard(title: 'Wellness', icon: Icons.spa_outlined, color: Colors.tealAccent)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 180)),
              ],
            ),

            // Add New Habit Button
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Add New Habit',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final bool hasNotification;
  const _HeaderIcon({required this.icon, this.hasNotification = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        if (hasNotification)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.secondaryLight, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}

class _RoutineTaskCard extends StatelessWidget {
  final String title;
  final List<Habit> habits;

  const _RoutineTaskCard({required this.title, required this.habits});

  @override
  Widget build(BuildContext context) {
    final done = habits.where((h) => h.isDone).length;
    final total = habits.length;
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.chevron_right, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              ),
              Text('$done/$total', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularHabitCard extends StatelessWidget {
  final String title;
  final String value;
  final String total;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;

  const _CircularHabitCard({
    required this.title,
    required this.value,
    required this.total,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 40 - 24) / 3;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E2E), // Solid dark teal from image
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(total.isNotEmpty ? '$value/$total' : value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      Text(unit, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 6)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title, 
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
              bool done = entry.key < 4; // Mock completion
              return Column(
                children: [
                  Text(entry.value, style: const TextStyle(color: Colors.white24, fontSize: 7)),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: done ? const Color(0xFF4ECDC4) : Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SmallCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SmallCategoryCard({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF263333),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withOpacity(0.6), size: 28),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
