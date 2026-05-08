import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';

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
    // 1. Filter habits to only include those completed today (or just isDone if that's the logic)
    // The user said "completed tasks per category". Usually this refers to today's progress.
    final completedHabits = habits.where((h) => h.isDone).toList();
    final totalCompleted = completedHabits.length;

    // 2. Group by category
    final Map<String, int> categoryCounts = {};
    for (var habit in completedHabits) {
      categoryCounts[habit.category] = (categoryCounts[habit.category] ?? 0) + 1;
    }

    // 3. Prepare data for the chart
    final List<ChartSegment> segments = [];
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
      segments.add(ChartSegment(
        count: count,
        color: category.color,
        name: categoryName,
      ));
    });

    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            "Focus Distribution",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: totalCompleted == 0
                    ? CircularProgressIndicator(
                        value: 0,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      )
                    : CustomPaint(
                        painter: DonutChartPainter(segments: segments, total: totalCompleted),
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
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (segments.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: segments.map((segment) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: segment.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: segment.color.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      segment.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
          else
            Text(
              "No tasks completed yet",
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class ChartSegment {
  final int count;
  final Color color;
  final String name;

  ChartSegment({required this.count, required this.color, required this.name});
}

class DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final int total;

  DonutChartPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 12.0;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background track
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(center, radius - strokeWidth / 2, paint);

    double startAngle = -math.pi / 2;

    for (var segment in segments) {
      final sweepAngle = (segment.count / total) * 2 * math.pi;
      paint.color = segment.color;
      
      // Draw shadow/glow effect for the segment (optional but looks premium)
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segment.color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + 0.05,
        sweepAngle - 0.1,
        false,
        glowPaint,
      );

      // Draw actual arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + 0.05,
        sweepAngle - 0.1,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
