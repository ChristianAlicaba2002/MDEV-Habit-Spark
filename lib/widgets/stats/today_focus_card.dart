import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/streak_service.dart';

class TodayFocusCard extends StatelessWidget {
  final List<Habit> habits;
  final String userId;
  final StreakService streakService;

  const TodayFocusCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Minimal vertical padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Left: Icon (Smaller)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.orangeAccent, size: 18),
          ),
          const SizedBox(width: 10),
          
          // Middle: Text and Progress (Force single line)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  remainingTasks > 0 
                    ? "You are $remainingTasks task away from your daily goal!"
                    : "Daily goal achieved!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12, // Slightly smaller to fit in line
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "$completedToday / $totalHabits habits completed",
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                    ),
                    const Spacer(),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 24,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withOpacity(0.05),
          ),

          // Right: Streak (Horizontal layout to save height)
          StreamBuilder<Map<String, dynamic>>(
            stream: streakService.getStreakStream(userId),
            builder: (context, snapshot) {
              final streak = snapshot.data?['currentStreak'] ?? 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "$streak",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
