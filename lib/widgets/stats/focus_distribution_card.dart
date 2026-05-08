import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';
import 'package:fl_chart/fl_chart.dart';

class FocusDistributionCard extends StatelessWidget {
  final List<Habit> habits;
  final List<CategoryModel> categories;
  final double height;

  const FocusDistributionCard({
    super.key,
    required this.habits,
    required this.categories,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final completedHabits = habits.where((h) => h.isDone).toList();
    final totalCompleted = completedHabits.length;

    final Map<String, int> categoryCounts = {};
    for (var habit in completedHabits) {
      categoryCounts[habit.category] = (categoryCounts[habit.category] ?? 0) + 1;
    }

    final List<PieChartSectionData> sections = [];
    categoryCounts.forEach((categoryName, count) {
      final category = categories.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => CategoryModel(
          id: '',
          name: categoryName,
          iconCode: '58713',
          colorValue: 0xFFFFC107,
          userId: '',
        ),
      );

      sections.add(
        PieChartSectionData(
          color: category.color,
          value: count.toDouble(),
          title: '', // Don't show title on segments
          radius: 12,
          showTitle: false,
          gradient: LinearGradient(
            colors: [category.color, category.color.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    });

    return Container(
      height: height,
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            "Focus Distribution",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15, // Reduced from 16
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Replaced Spacer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100, // Reduced from 120
                height: 100, // Reduced from 120
                child: totalCompleted == 0
                    ? PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.white.withOpacity(0.05),
                              value: 1,
                              radius: 10, // Reduced from 12
                              showTitle: false,
                            ),
                          ],
                          centerSpaceRadius: 35, // Reduced from 40
                          sectionsSpace: 0,
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 35, // Reduced from 40
                          sectionsSpace: 3, // Reduced from 4
                          startDegreeOffset: -90,
                        ),
                      ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$totalCompleted",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24, // Reduced from 28
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tasks",
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 10, // Reduced from 12
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12), // Replaced Spacer
          if (categoryCounts.isNotEmpty)
            Expanded( // Added Expanded to allow scroll if many categories
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10, // Reduced from 12
                  runSpacing: 6, // Reduced from 8
                  alignment: WrapAlignment.center,
                  children: categoryCounts.keys.map((categoryName) {
                    final category = categories.firstWhere(
                      (c) => c.name == categoryName,
                      orElse: () => CategoryModel(
                        id: '',
                        name: categoryName,
                        iconCode: '58713',
                        colorValue: 0xFFFFC107,
                        userId: '',
                      ),
                    );
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, // Reduced from 8
                          height: 6, // Reduced from 8
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: category.color.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4), // Reduced from 6
                        Text(
                          categoryName,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 10, // Reduced from 11
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
          else
            Text(
              "No tasks completed yet",
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
    );
  }
}
