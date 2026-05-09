import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:intl/intl.dart';

class ConsistencyCard extends StatelessWidget {
  final List<Habit> habits;
  final String userId;
  final double height;
  final HabitLogService _logService = HabitLogService();

  ConsistencyCard({
    super.key,
    required this.habits,
    required this.userId,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Consistency",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          StreamBuilder<List<HabitLog>>(
            stream: _logService.getUserLogsStream(userId),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              final now = DateTime.now();
              final monday = now.subtract(Duration(days: now.weekday - 1));
              
              int consistentCount = 0;
              List<Widget> dayWidgets = [];

              for (int i = 0; i < 7; i++) {
                final day = DateTime(monday.year, monday.month, monday.day).add(Duration(days: i));
                final dayLogs = logs.where((log) {
                  final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
                  return log.isCompleted && logDate.isAtSameMomentAs(day);
                }).toList();

                if (dayLogs.isNotEmpty) consistentCount++;

                dayWidgets.add(
                  Expanded(
                    child: _DayIcon(
                      dayName: DateFormat('E').format(day).substring(0, 2),
                      isCompleted: dayLogs.isNotEmpty,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Row(children: dayWidgets),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Weekly consistency",
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$consistentCount ",
                              style: GoogleFonts.outfit(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            TextSpan(
                              text: "/ 7",
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _DayIcon extends StatelessWidget {
  final String dayName;
  final bool isCompleted;

  const _DayIcon({
    required this.dayName,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? Colors.orange : Colors.white10,
              width: 1.5,
            ),
          ),
          child: isCompleted 
            ? const Center(child: Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 14))
            : null,
        ),
        const SizedBox(height: 6),
        Text(
          dayName,
          style: GoogleFonts.outfit(
            color: isCompleted ? Colors.white70 : Colors.white24,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
