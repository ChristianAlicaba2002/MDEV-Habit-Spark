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
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20), // More consistent radius
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Highest Habit Streak",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14, // Smaller title
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          StreamBuilder<List<HabitLog>>(
            stream: _logService.getUserLogsStream(userId),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              String bestHabitName = "No active streak";
              int maxStreak = 0;

              if (logs.isNotEmpty && habits.isNotEmpty) {
                for (var habit in habits) {
                  final habitLogs = logs
                      .where((l) => l.habitId == habit.id && l.isCompleted)
                      .map((l) => DateTime(l.completedAt.year, l.completedAt.month, l.completedAt.day))
                      .toSet()
                      .toList();
                  habitLogs.sort((a, b) => b.compareTo(a));

                  int streak = 0;
                  if (habitLogs.isNotEmpty) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final yesterday = today.subtract(const Duration(days: 1));

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
                  mainAxisSize: MainAxisSize.min,
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
                        size: 40, // Reduced from 64
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced gap
                    Text(
                      "$maxStreak",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28, // Reduced from 42
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Days — $bestHabitName",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10, // Reduced from 12
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
