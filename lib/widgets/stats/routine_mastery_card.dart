import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';

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
          Text(
            "Routine Mastery",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _RoutineItem(
            label: "Morning Routine",
            icon: Icons.wb_sunny_rounded,
            color: Colors.orangeAccent,
            percentage: 90,
          ),
          const SizedBox(height: 16),
          _RoutineItem(
            label: "Afternoon Routine",
            icon: Icons.beach_access_rounded,
            color: Colors.lightBlueAccent,
            percentage: 40,
          ),
          const SizedBox(height: 16),
          _RoutineItem(
            label: "Night Routine",
            icon: Icons.nightlight_round,
            color: Colors.purpleAccent,
            percentage: 70,
          ),
        ],
      ),
    );
  }
}

class _RoutineItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int percentage;

  const _RoutineItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
              ),
            ),
            Text(
              "$percentage%",
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
