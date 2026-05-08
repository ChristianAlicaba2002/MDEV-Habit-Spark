import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';

class TodayFocusCard extends StatelessWidget {
  final List<Habit> habits;
  final String userId;
  final HabitLogService _logService = HabitLogService();

  TodayFocusCard({
    super.key,
    required this.habits,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final remainingTasks = habits.where((h) => !h.isDone).length;
    final completedToday = habits.where((h) => h.isDone).length;

    return StreamBuilder<List<HabitLog>>(
      stream: _logService.getUserLogsStream(userId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        String insights = "Focusing on your goals...";

        if (remainingTasks > 0) {
          insights = "You are $remainingTasks ${remainingTasks == 1 ? 'task' : 'tasks'} away from your daily goal!";
        } else if (completedToday > 0) {
          // Calculate most productive time if all done
          if (logs.isNotEmpty) {
            final Map<int, int> hourCounts = {};
            for (var log in logs) {
              final hour = log.completedAt.hour;
              hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
            }
            
            var bestHour = -1;
            var maxCount = 0;
            hourCounts.forEach((hour, count) {
              if (count > maxCount) {
                maxCount = count;
                bestHour = hour;
              }
            });

            if (bestHour != -1) {
              final period = bestHour >= 12 ? 'PM' : 'AM';
              final displayHour = bestHour == 0 ? 12 : (bestHour > 12 ? bestHour - 12 : bestHour);
              insights = "Most productive time: $displayHour:00 $period";
            }
          } else {
            insights = "Amazing! You've crushed all your tasks today!";
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent.withOpacity(0.15),
                Colors.orange.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  insights,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
              ),
            ],
          ),
        );
      },
    );
  }
}
