import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';

class StreakCard extends StatelessWidget {
  final String userId;
  final List<Habit> habits;
  final double height;
  final HabitLogService _logService = HabitLogService();

  StreakCard({
    super.key,
    required this.userId,
    required this.habits,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Highest Habit Streak",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          StreamBuilder<List<HabitLog>>(
            stream: _logService.getUserLogsStream(userId),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              
              // Calculate streaks for each habit
              String bestHabitName = "No active streak";
              int maxStreak = 0;

              if (logs.isNotEmpty && habits.isNotEmpty) {
                for (var habit in habits) {
                  final habitLogs = logs
                      .where((l) => l.habitId == habit.id && l.isCompleted)
                      .map((l) => DateTime(l.completedAt.year, l.completedAt.month, l.completedAt.day))
                      .toSet()
                      .toList();
                  
                  habitLogs.sort((a, b) => b.compareTo(a)); // Newest first

                  int streak = 0;
                  if (habitLogs.isNotEmpty) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final yesterday = today.subtract(const Duration(days: 1));

                    // Check if streak is still active (today or yesterday)
                    if (habitLogs.first.isAtSameMomentAs(today) || habitLogs.first.isAtSameMomentAs(yesterday)) {
                      streak = 1;
                      for (int i = 0; i < habitLogs.length - 1; i++) {
                        if (habitLogs[i].difference(habitLogs[i + 1]).inDays == 1) {
                          streak++;
                        } else {
                          break;
                        }
                      }
                    }
                  }

                  if (streak > maxStreak) {
                    maxStreak = streak;
                    bestHabitName = habit.name;
                  }
                }
              }

              return Center(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.orange, Colors.red],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Icon(
                        CupertinoIcons.flame_fill,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$maxStreak",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Days — $bestHabitName",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
