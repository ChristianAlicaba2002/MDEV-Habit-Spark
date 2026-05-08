import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';

class ContributionHeatmapCard extends StatelessWidget {
  final String userId;
  final List<Habit> habits;
  final HabitLogService _logService = HabitLogService();

  ContributionHeatmapCard({
    super.key,
    required this.userId,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HabitLog>>(
      stream: _logService.getUserLogsStream(userId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final Map<DateTime, int> datasets = {};

        for (var log in logs) {
          if (log.isCompleted) {
            final date = DateTime(
              log.completedAt.year,
              log.completedAt.month,
              log.completedAt.day,
            );
            datasets[date] = (datasets[date] ?? 0) + 1;
          }
        }

        final now = DateTime.now();
        // Starting from the first Sunday of Jan to avoid the "Dec" label overlap
        final startDate = DateTime(now.year, 1, 4); 
        final endDate = DateTime(now.year, 12, 31);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded, color: Colors.cyanAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Contribution Activity",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _LegendItem(color: Colors.white.withOpacity(0.02), label: "0"),
                      const SizedBox(width: 8),
                      _LegendItem(color: const Color(0xFF9575CD), label: "1-3"),
                      const SizedBox(width: 8),
                      _LegendItem(color: const Color(0xFF00E5FF), label: "All"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: HeatMap(
                  datasets: datasets,
                  colorMode: ColorMode.color,
                  defaultColor: Colors.white.withOpacity(0.02),
                  textColor: Colors.white38,
                  showColorTip: false,
                  showText: false,
                  scrollable: false,
                  size: 16,
                  fontSize: 10,
                  // Using built-in labels to avoid duplicates
                  startDate: startDate,
                  endDate: endDate,
                  colorsets: {
                    1: const Color(0xFF9575CD),
                    4: const Color(0xFF00E5FF),
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}
