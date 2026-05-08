import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';

class TrendsCard extends StatelessWidget {
  final String category;
  final List<Habit> habits;
  final List<CategoryModel> categories;

  const TrendsCard({
    super.key,
    required this.category,
    required this.habits,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final categoryHabits = habits.where((h) => h.category == category).toList();
    final catInfo = categories.firstWhere(
      (c) => c.name == category,
      orElse: () => CategoryModel(
        id: '',
        name: 'General',
        iconCode: '58713',
        colorValue: 0xFFFFC107,
        userId: '',
      ),
    );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$category Trends",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(CupertinoIcons.chevron_up, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          if (categoryHabits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "No tasks in $category",
                  style: GoogleFonts.outfit(color: Colors.white24, fontSize: 13),
                ),
              ),
            )
          else
            ...categoryHabits.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HabitTrendBar(habit: h, color: catInfo.color),
            )).toList(),
        ],
      ),
    );
  }
}

class _HabitTrendBar extends StatelessWidget {
  final Habit habit;
  final Color color;
  const _HabitTrendBar({required this.habit, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = habit.isDone ? 1.0 : 0.1;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            habit.name,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          habit.isDone ? "100%" : "0%",
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
