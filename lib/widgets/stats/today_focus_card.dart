import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:habit_spark/services/streak_service.dart';

class TodayFocusCard extends StatelessWidget {
  final List<Habit> habits;
  final String userId;
  final StreakService streakService;
  final HabitLogService _logService = HabitLogService();

  TodayFocusCard({
    super.key,
    required this.habits,
    required this.userId,
    required this.streakService,
  });

  @override
  Widget build(BuildContext context) {
    final completedToday = habits.where((h) => h.isDone).length;
    final totalHabits = habits.length;
    final remainingTasks = totalHabits - completedToday;
    final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Left Side: Icon & Progress
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_rounded, color: Colors.orangeAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remainingTasks > 0 
                          ? "You are $remainingTasks task away from your daily goal!"
                          : "You've achieved your daily goal!",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$completedToday / $totalHabits habits completed",
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 60,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withOpacity(0.1),
          ),

          // Right Side: Streak
          StreamBuilder<Map<String, dynamic>>(
            stream: streakService.getStreakStream(userId),
            builder: (context, snapshot) {
              final streak = snapshot.data?['currentStreak'] ?? 0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    "$streak",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "day streak",
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
