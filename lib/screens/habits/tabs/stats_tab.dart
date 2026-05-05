import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
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

                  // ── Time Frame Selector (Week/Month/Year)
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

                  // ── Workout Trends Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _WorkoutTrendsCard(),
                    ),
                  ),

                  // ── Active Minutes & Habit Consistency Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _ActiveMinutesCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _HabitConsistencyCard(habits: widget.habits)),
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
                          const Expanded(child: _PersonalRecordsCard()),
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

// ── Workout Trends Card ──
class _WorkoutTrendsCard extends StatelessWidget {
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
          _TrendBar(label: "Running", progress1: 0.85, progress2: 0.7, color1: Colors.orange, color2: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          _TrendBar(label: "Lifting", progress1: 0.75, progress2: 0.6, color1: const Color(0xFF4DB6AC), color2: Colors.brown.withOpacity(0.4)),
          const SizedBox(height: 16),
          _TrendBar(label: "Yoga", progress1: 0.5, progress2: 0.8, color1: Colors.orange.withOpacity(0.6), color2: const Color(0xFF4DB6AC).withOpacity(0.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TrendLegend(label: "Running", color: Colors.orange),
              const SizedBox(width: 12),
              _TrendLegend(label: "Lifting", color: Colors.brown.withOpacity(0.6)),
              const SizedBox(width: 12),
              _TrendLegend(label: "Yoga", color: const Color(0xFF4DB6AC)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  final String label;
  final double progress1;
  final double progress2;
  final Color color1;
  final Color color2;

  const _TrendBar({required this.label, required this.progress1, required this.progress2, required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13))),
        Expanded(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(4))),
                  FractionallySizedBox(widthFactor: progress1, child: Container(height: 8, decoration: BoxDecoration(color: color1, borderRadius: BorderRadius.circular(4)))),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(4))),
                  FractionallySizedBox(widthFactor: progress2, child: Container(height: 8, decoration: BoxDecoration(color: color2, borderRadius: BorderRadius.circular(4)))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _TrendLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

// ── Active Minutes Card ──
class _ActiveMinutesCard extends StatelessWidget {
  const _ActiveMinutesCard();

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
          Text("Active Minutes", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("(Weekly Avg)", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.arrow_drop_up, color: Colors.green, size: 16),
                  Text("16 %", style: GoogleFonts.outfit(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("620", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_drop_up, color: Colors.green, size: 12),
                        Text("100%", style: GoogleFonts.outfit(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text("vs last week", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11))),
        ],
      ),
    );
  }
}

// ── Habit Consistency Card ──
class _HabitConsistencyCard extends StatelessWidget {
  final List<Habit> habits;
  const _HabitConsistencyCard({required this.habits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Habit Consistency", 
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 2),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("All Habits", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85, // Adjusted to prevent vertical overflow
            children: [
              _ConsistencyItem(icon: Icons.water_drop, color: Colors.cyan, progress: 0.45),
              _ConsistencyItem(icon: Icons.menu_book, color: Colors.orange, progress: 0.5),
              _ConsistencyItem(icon: Icons.self_improvement, color: Colors.orange, progress: 0.75),
              _ConsistencyItem(icon: Icons.eco, color: Colors.green, progress: 0.4),
              _ConsistencyItem(icon: Icons.lightbulb, color: Colors.orange, progress: 0.2),
              _ConsistencyItem(icon: Icons.mic, color: Colors.orange, progress: 0.1),
            ],
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
  const _ConsistencyItem({required this.icon, required this.color, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 30, // Reduced from 36
              height: 30,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color.withOpacity(0.8), size: 14), // Reduced from 18
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(child: Text("${(progress * 100).toInt()}%", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10))),
      ],
    );
  }
}

// ── Heart Rate Recovery Card ──
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
          Text("Heart Rate Recovery", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _RecoveryLinePainter()),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Low", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
              Text("30%", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
              Text("High", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Center(child: Text("Exercise Intensity", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11))),
        ],
      ),
    );
  }
}

class _RecoveryLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dotPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.75, size.height * 0.8),
      Offset(size.width, size.height * 0.9),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }

    // Grid lines
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for(int i=0; i<5; i++) {
      double y = size.height * (i/4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(path, paint);

    for (var point in points) {
      canvas.drawCircle(point, 3, dotPaint);
      canvas.drawCircle(point, 6, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Personal Records Card ──
class _PersonalRecordsCard extends StatelessWidget {
  const _PersonalRecordsCard();

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
          Text("Personal Records", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("(PRs)", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 16),
          _PRItem(label: "Fastest 5k Pace", value: "4:30 /km"),
          const SizedBox(height: 12),
          _PRItem(label: "Max Bench", value: "90kg"),
          const SizedBox(height: 12),
          _PRItem(label: "Max Bench", value: "90kg"), // Replicated from image
        ],
      ),
    );
  }
}

class _PRItem extends StatelessWidget {
  final String label;
  final String value;
  const _PRItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value.split(' ')[0], 
                style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)
              ),
              if (value.contains(' '))
                TextSpan(
                  text: ' ${value.split(' ')[1]}', 
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13)
                ),
            ],
          ),
        ),
      ],
    );
  }
}
