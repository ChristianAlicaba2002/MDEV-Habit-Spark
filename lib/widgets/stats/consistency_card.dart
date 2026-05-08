import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';

class ConsistencyCard extends StatelessWidget {
  final List<Habit> habits;
  final double height;

  const ConsistencyCard({
    super.key,
    required this.habits,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final displayHabits = habits.take(6).toList();
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10), // Reduced from 12
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "Consistency",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
          if (displayHabits.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "No habits",
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 4, // Reduced from 8
                crossAxisSpacing: 2, // Reduced from 4
                physics: const NeverScrollableScrollPhysics(),
                children: displayHabits.map((h) => _ConsistencyItem(
                  icon: h.icon != null ? IconData(int.parse(h.icon!), fontFamily: 'MaterialIcons') : Icons.check,
                  progress: h.isDone ? 1.0 : 0.0,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsistencyItem extends StatelessWidget {
  final IconData icon;
  final double progress;
  const _ConsistencyItem({required this.icon, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 28, // Reduced from 32
              height: 28, // Reduced from 32
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.0,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation(Colors.orange),
                strokeCap: StrokeCap.round,
              ),
            ),
            Icon(icon, color: Colors.orange.withOpacity(0.8), size: 12), // Reduced from 14
          ],
        ),
        const SizedBox(height: 2), // Reduced from 4
        Text(
          "${(progress * 100).toInt()}%",
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 7, // Reduced from 8
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
