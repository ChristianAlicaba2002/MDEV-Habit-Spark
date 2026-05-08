import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class RoutineMasteryCard extends StatelessWidget {
  final List<Habit> habits;
  final double height;

  const RoutineMasteryCard({
    super.key,
    required this.habits,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final morningHabits = habits.where((h) => h.routine == 'Morning').toList();
    final afternoonHabits = habits.where((h) => h.routine == 'Afternoon').toList();

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
            "Routine Mastery",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _RoutineProgressBar(
            label: "Morning",
            icon: LucideIcons.sun,
            iconColor: Colors.orangeAccent,
            habits: morningHabits,
          ),
          const SizedBox(height: 20),
          _RoutineProgressBar(
            label: "Afternoon",
            icon: LucideIcons.sunset,
            iconColor: Colors.lightBlueAccent,
            habits: afternoonHabits,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _RoutineProgressBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<Habit> habits;

  const _RoutineProgressBar({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final total = habits.length;
    final completed = habits.where((h) => h.isDone).length;
    final progress = total > 0 ? completed / total : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              "$completed/$total ($percentage%)",
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 10,
              width: MediaQuery.of(context).size.width * 0.35 * progress, // Approximation for half card
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor, iconColor.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
