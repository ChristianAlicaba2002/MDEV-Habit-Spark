import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';

class ContributionHeatmapCard extends StatelessWidget {
  final String userId;
  final HabitLogService _logService = HabitLogService();

  ContributionHeatmapCard({super.key, required this.userId});

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
            "Contribution Heatmap",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<HabitLog>>(
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

              return HeatMap(
                datasets: datasets,
                colorMode: ColorMode.color,
                defaultColor: Colors.white.withOpacity(0.02),
                textColor: Colors.white38,
                showColorTip: false,
                showText: false,
                scrollable: true,
                size: 20,
                fontSize: 10,
                onClick: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(value.toString())),
                  );
                },
                colorsets: {
                  1: const Color(0xFF4A148C), // Deep Purple
                  2: const Color(0xFF7B1FA2), // Purple
                  3: const Color(0xFF3F51B5), // Indigo
                  4: const Color(0xFF2196F3), // Blue
                  5: const Color(0xFF00BCD4), // Cyan
                  6: const Color(0xFF00E5FF), // Bright Cyan
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
