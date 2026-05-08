import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';

class RadarChartCard extends StatelessWidget {
  final List<Habit> habits;
  final List<CategoryModel> categories;

  const RadarChartCard({
    super.key,
    required this.habits,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryProgress = {};
    for (var cat in categories) {
      final catHabits = habits.where((h) => h.category == cat.name).toList();
      categoryProgress[cat.name] = catHabits.isEmpty ? 0.0 : (catHabits.where((h) => h.isDone).length / catHabits.length) * 100;
    }

    final radarCategories = categories.take(4).toList(); // Matching screenshot's 4 axes
    final dataSets = [
      RadarDataSet(
        fillColor: Colors.cyanAccent.withOpacity(0.2),
        borderColor: Colors.cyanAccent,
        entryRadius: 3,
        dataEntries: radarCategories.map((cat) => RadarEntry(value: categoryProgress[cat.name] ?? 0)).toList(),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Left: Info & Legend
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Routine Balance",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your category focus across the board",
                  style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10),
                ),
                const SizedBox(height: 30),
                ...radarCategories.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cat.name,
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          // Right: Radar Chart
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 180,
              child: RadarChart(
                RadarChartData(
                  dataSets: dataSets,
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.white10),
                  titlePositionPercentageOffset: 0.15,
                  titleTextStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 9),
                  getTitle: (index, angle) => RadarChartTitle(text: radarCategories[index].name),
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  gridBorderData: const BorderSide(color: Colors.white10, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
