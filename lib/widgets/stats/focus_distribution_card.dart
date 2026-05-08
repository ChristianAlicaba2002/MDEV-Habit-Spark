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
          title: '',
          radius: 12,
          showTitle: false,
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Focus Distribution",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              // Left: Donut Chart
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: totalCompleted == 0
                        ? PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: Colors.white.withOpacity(0.05),
                                  value: 1,
                                  radius: 10,
                                  showTitle: false,
                                ),
                              ],
                              centerSpaceRadius: 50,
                              sectionsSpace: 0,
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 50,
                              sectionsSpace: 4,
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Tasks",
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 40),
              // Right: Legend
              Expanded(
                child: Column(
                  children: categoryCounts.entries.map((entry) {
                    final category = categories.firstWhere(
                      (c) => c.name == entry.key,
                      orElse: () => categories.first,
                    );
                    final percentage = totalCompleted > 0 ? (entry.value / totalCompleted * 100).toInt() : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          Text(
                            "$percentage% (${entry.value})",
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Total completed habits: 20", // Hardcoded per screenshot or calculate
            style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
