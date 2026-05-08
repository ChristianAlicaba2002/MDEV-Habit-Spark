import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:intl/intl.dart';

class VelocityGraphCard extends StatelessWidget {
  final String userId;
  final HabitLogService _logService = HabitLogService();

  VelocityGraphCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Weekly Velocity",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "+28%",
                  style: GoogleFonts.outfit(
                    color: Colors.cyanAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "Momentum vs last week",
            style: GoogleFonts.outfit(color: Colors.white24, fontSize: 9),
          ),
          const Spacer(),
          SizedBox(
            height: 60, // Shrunk from 100 to fit rectangle
            child: StreamBuilder<List<HabitLog>>(
              stream: _logService.getUserLogsStream(userId),
              builder: (context, snapshot) {
                final logs = snapshot.data ?? [];
                final List<FlSpot> spots = [];
                final now = DateTime.now();
                
                for (int i = 6; i >= 0; i--) {
                  final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
                  final count = logs.where((log) {
                    final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
                    return log.isCompleted && logDate.isAtSameMomentAs(day);
                  }).length;
                  spots.add(FlSpot((6 - i).toDouble(), count.toDouble()));
                }

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = now.subtract(Duration(days: 6 - value.toInt()));
                            return Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: const TextStyle(color: Colors.white24, fontSize: 8),
                            );
                          },
                          reservedSize: 14,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.cyanAccent,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false), // Hide dots to save space
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [Colors.cyanAccent.withOpacity(0.15), Colors.cyanAccent.withOpacity(0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
