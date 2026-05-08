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
    // Calculate completion percentage per category
    final Map<String, double> categoryProgress = {};
    for (var cat in categories) {
      final catHabits = habits.where((h) => h.category == cat.name).toList();
      if (catHabits.isEmpty) {
        categoryProgress[cat.name] = 0.0;
      } else {
        final done = catHabits.where((h) => h.isDone).length;
        categoryProgress[cat.name] = (done / catHabits.length) * 100;
      }
    }

    final List<RadarDataSet> dataSets = [
      RadarDataSet(
        fillColor: Colors.cyanAccent.withOpacity(0.2),
        borderColor: Colors.cyanAccent,
        entryRadius: 3,
        dataEntries: categories.map((cat) {
          return RadarEntry(value: categoryProgress[cat.name] ?? 0);
        }).toList(),
      ),
    ];

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
            "Daily Routine Balance",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your category focus across the board",
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: dataSets,
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.white10),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                getTitle: (index, angle) {
                  if (index >= categories.length) return const RadarChartTitle(text: '');
                  return RadarChartTitle(text: categories[index].name);
                },
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: const BorderSide(color: Colors.white10, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
