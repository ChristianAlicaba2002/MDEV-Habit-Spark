import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/health_service.dart';

class StatsTab extends StatefulWidget {
  final String userId;
  final List<Habit> habits;
  final StreakService streakService;

  const StatsTab({
    super.key,
    required this.userId,
    required this.habits,
    required this.streakService,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String _selectedTimeFrame = 'Week';
  final HealthService _healthService = HealthService();

  @override
  Widget build(BuildContext context) {
    // Real-time calculation for Consistency based on incoming habits
    final completedHabits = widget.habits.where((h) => h.isDone).length;
    final totalHabits = widget.habits.length;
    final overallConsistency = totalHabits > 0 ? completedHabits / totalHabits : 0.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E3E),
            Color(0xFF4A6666),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Activity Stats",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Time Frame Selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: ['Week', 'Month', 'Year'].map((time) {
                            bool isSelected = _selectedTimeFrame == time;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTimeFrame = time),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      time,
                                      style: GoogleFonts.outfit(
                                        color: isSelected ? Colors.white : Colors.white60,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // ── Workout Trends Section (Connected to HealthService)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _RealWorkoutTrendsCard(healthService: _healthService),
                    ),
                  ),

                  // ── Active Minutes & Habit Consistency Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _RealActiveMinutesCard(healthService: _healthService)),
                          const SizedBox(width: 16),
                          Expanded(child: _RealHabitConsistencyCard(habits: widget.habits)),
                        ],
                      ),
                    ),
                  ),

                  // ── Heart Rate Recovery & PRs Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _HeartRateRecoveryCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _RealPersonalRecordsCard(healthService: _healthService)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── REAL Workout Trends Card ──
class _RealWorkoutTrendsCard extends StatelessWidget {
  final HealthService healthService;
  const _RealWorkoutTrendsCard({required this.healthService});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Workout Trends", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(CupertinoIcons.chevron_up, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          _TrendStreamBar(label: "Running", healthService: healthService, color: Colors.orange),
          const SizedBox(height: 16),
          _TrendStreamBar(label: "Lifting", healthService: healthService, color: const Color(0xFF4DB6AC)),
          const SizedBox(height: 16),
          _TrendStreamBar(label: "Yoga", healthService: healthService, color: Colors.brown.withOpacity(0.6)),
        ],
      ),
    );
  }
}

class _TrendStreamBar extends StatelessWidget {
  final String label;
  final HealthService healthService;
  final Color color;

  const _TrendStreamBar({required this.label, required this.healthService, required this.color});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: healthService.getActivityMonthlyStats(label),
      builder: (context, snapshot) {
        final total = snapshot.data?['total'] ?? 0.0;
        // Normalize against a target (e.g., 100 units per month)
        final progress = (total / 100.0).clamp(0.0, 1.0);

        return Row(
          children: [
            SizedBox(width: 60, child: Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13))),
            Expanded(
              child: Stack(
                children: [
                  Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(4))),
                  FractionallySizedBox(widthFactor: progress, child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text("${total.toInt()}", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
          ],
        );
      }
    );
  }
}

// ── REAL Active Minutes Card ──
class _RealActiveMinutesCard extends StatelessWidget {
  final HealthService healthService;
  const _RealActiveMinutesCard({required this.healthService});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return StreamBuilder<double>(
      stream: healthService.getTypeTotalForPeriod('minutes', start, end),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0.0;
        final progress = (total / 60.0).clamp(0.0, 1.0); // Target 60 mins

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Active Minutes", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    Text("${total.toInt()}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text("Today's Goal", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10))),
            ],
          ),
        );
      }
    );
  }
}

// ── REAL Habit Consistency Card (Connected to Habits from Home) ──
class _RealHabitConsistencyCard extends StatelessWidget {
  final List<Habit> habits;
  const _RealHabitConsistencyCard({required this.habits});

  @override
  Widget build(BuildContext context) {
    // Show top 6 habits from the real habits list
    final displayHabits = habits.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Habit Consistency", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Current Habits", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 12),
          if (displayHabits.isEmpty)
             Center(child: Text("No habits yet", style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10)))
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: displayHabits.map((h) => _ConsistencyItem(
                icon: h.icon != null ? IconData(int.parse(h.icon!), fontFamily: 'MaterialIcons') : Icons.check,
                color: Colors.orange,
                progress: h.isDone ? 1.0 : 0.0,
                label: h.name,
              )).toList(),
            ),
        ],
      ),
    );
  }
}

class _ConsistencyItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double progress;
  final String label;
  const _ConsistencyItem({required this.icon, required this.color, required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color.withOpacity(0.8), size: 14),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(child: Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 8))),
      ],
    );
  }
}

// ── Heart Rate Recovery Card (Static Mock) ──
class _HeartRateRecoveryCard extends StatelessWidget {
  const _HeartRateRecoveryCard();

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
          Text("Heart Rate Recovery", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(painter: _RecoveryLinePainter()),
          ),
          const SizedBox(height: 12),
          Center(child: Text("Exercise Intensity", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11))),
        ],
      ),
    );
  }
}

class _RecoveryLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.orange.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2;
    final dotPaint = Paint()..color = Colors.orange..style = PaintingStyle.fill;
    
    final path = Path();
    final points = [
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width, size.height * 0.9),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }

    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for(int i=0; i<4; i++) {
      double y = size.height * (i/3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(path, paint);
    for (var point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── REAL Personal Records Card ──
class _RealPersonalRecordsCard extends StatelessWidget {
  final HealthService healthService;
  const _RealPersonalRecordsCard({required this.healthService});

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
          Text("Personal Records", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Fetching specific records
          _PRStreamItem(label: "Longest Run", type: "running", unit: "km", healthService: healthService),
          const SizedBox(height: 12),
          _PRStreamItem(label: "Max Lift", type: "lifting", unit: "kg", healthService: healthService),
        ],
      ),
    );
  }
}

class _PRStreamItem extends StatelessWidget {
  final String label;
  final String type;
  final String unit;
  final HealthService healthService;

  const _PRStreamItem({required this.label, required this.type, required this.unit, required this.healthService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: healthService.getActivityMonthlyStats(type),
      builder: (context, snapshot) {
        final total = snapshot.data?['total'] ?? 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${total.toInt()}", 
                    style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                    text: " $unit", 
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
