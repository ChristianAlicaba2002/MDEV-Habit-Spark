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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Contribution Activity",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: ['Mar', 'Apr', 'May']
                                .map((m) => Padding(
                                      padding: const EdgeInsets.only(right: 60),
                                      child: Text(m, style: const TextStyle(color: Colors.white24, fontSize: 10)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          HeatMap(
                            datasets: datasets,
                            colorMode: ColorMode.color,
                            defaultColor: Colors.white.withOpacity(0.02),
                            textColor: Colors.white38,
                            showColorTip: false,
                            showText: false,
                            scrollable: false,
                            size: 18,
                            fontSize: 10,
                            colorsets: {
                              1: const Color(0xFF9575CD), // Light Purple
                              4: const Color(0xFF00E5FF), // Glowing Cyan
                            },
                            startDate: DateTime.now().subtract(const Duration(days: 90)),
                            endDate: DateTime.now(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        "Your consistency\noverview",
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, height: 1.4),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _LegendItem(color: Colors.white.withOpacity(0.02), label: "0"),
                  const SizedBox(width: 12),
                  _LegendItem(color: const Color(0xFF9575CD), label: "1-3"),
                  const SizedBox(width: 12),
                  _LegendItem(color: const Color(0xFF00E5FF), label: "All"),
                ],
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
