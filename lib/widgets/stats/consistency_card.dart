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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Consistency",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<HabitLog>>(
              stream: _logService.getUserLogsStream(userId),
              builder: (context, snapshot) {
                final logs = snapshot.data ?? [];
                
                // Get Mon-Sun of current week
                final now = DateTime.now();
                final monday = now.subtract(Duration(days: now.weekday - 1));
                
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(7, (index) {
                        final day = DateTime(monday.year, monday.month, monday.day).add(Duration(days: index));
                        final dayLogs = logs.where((log) {
                          final logDate = DateTime(log.completedAt.year, log.completedAt.month, log.completedAt.day);
                          return log.isCompleted && logDate.isAtSameMomentAs(day);
                        }).toList();

                        // Get icon from first completed habit of that day
                        IconData? displayIcon;
                        Color? displayColor;
                        
                        if (dayLogs.isNotEmpty) {
                          final firstLogHabitId = dayLogs.first.habitId;
                          final habit = habits.firstWhere((h) => h.id == firstLogHabitId, orElse: () => habits.first);
                          displayIcon = habit.icon != null ? IconData(int.parse(habit.icon!), fontFamily: 'MaterialIcons') : Icons.check;
                          displayColor = Colors.orange; // Default or category color
                        }

                        return _DayIcon(
                          dayName: DateFormat('E').format(day).substring(0, 2),
                          icon: displayIcon,
                          isCompleted: dayLogs.isNotEmpty,
                          color: displayColor ?? Colors.white.withOpacity(0.05),
                        );
                      }),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayIcon extends StatelessWidget {
  final String dayName;
  final IconData? icon;
  final bool isCompleted;
  final Color color;

  const _DayIcon({
    required this.dayName,
    this.icon,
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isCompleted ? color.withOpacity(0.2) : Colors.white.withOpacity(0.02),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? color : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: isCompleted ? [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ] : null,
          ),
          child: Icon(
            icon ?? Icons.circle,
            size: 16,
            color: isCompleted ? color : Colors.white10,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dayName,
          style: GoogleFonts.outfit(
            color: isCompleted ? Colors.white : Colors.white24,
            fontSize: 10,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
