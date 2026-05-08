import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';

class ContributionHeatmapCard extends StatelessWidget {
  final String userId;
  final List<Habit> habits; // Added habits to check "all habits completed"
  final HabitLogService _logService = HabitLogService();

  ContributionHeatmapCard({
    super.key,
    required this.userId,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final totalHabitsCount = habits.length;

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
                size: 28, // Slightly larger for the "7x5" feel
                fontSize: 10,
                colorsets: {
                  1: const Color(0xFF9575CD), // Light Purple (1-3 habits)
                  4: const Color(0xFF00E5FF), // Glowing Cyan/Green (4+ habits or all)
                },
                // Customizing the labels/months if needed
                startDate: DateTime.now().subtract(const Duration(days: 34)),
                endDate: DateTime.now(),
                onClick: (value) {
                  // Optional interaction
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ColorLegend(color: Colors.white.withOpacity(0.02), label: "0"),
              const SizedBox(width: 8),
              _ColorLegend(color: const Color(0xFF9575CD), label: "1-3"),
              const SizedBox(width: 8),
              _ColorLegend(color: const Color(0xFF00E5FF), label: "All"),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
