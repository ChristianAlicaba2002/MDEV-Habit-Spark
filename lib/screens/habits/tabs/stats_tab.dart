import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  int _selectedCategoryIndex = 0;

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
        bottom: false,
        child: Column(
          children: [
            // ── Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RoundIconButton(
                    icon: CupertinoIcons.arrow_left,
                    onTap: () {},
                    outlined: true,
                  ),
                  const Text(
                    'Statistic',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  RoundIconButton(
                    icon: CupertinoIcons.ellipsis,
                    onTap: () {},
                    outlined: true,
                  ),
                ],
              ),
            ),

            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Category Selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryPill(
                              label: 'Steps',
                              icon: CupertinoIcons.paw,
                              selected: _selectedCategoryIndex == 0,
                              onTap: () => setState(() => _selectedCategoryIndex = 0),
                            ),
                            const SizedBox(width: 12),
                            _CategoryPill(
                              label: 'Steps',
                              icon: CupertinoIcons.heart_fill,
                              selected: _selectedCategoryIndex == 1,
                              onTap: () => setState(() => _selectedCategoryIndex = 1),
                            ),
                            const SizedBox(width: 12),
                            _CategoryPill(
                              label: 'Regularity',
                              icon: CupertinoIcons.chart_bar_alt_fill,
                              selected: _selectedCategoryIndex == 2,
                              onTap: () => setState(() => _selectedCategoryIndex = 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Average Steps Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 30,
                        blur: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '5,400 ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'average steps',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'This Week',
                                        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(CupertinoIcons.chevron_down, color: Colors.black, size: 12),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const _StatsBarChart(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Recent Workout Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent workout',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'See all',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Workout Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Heart Rate Card
                            const Expanded(
                              flex: 5,
                              child: GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _IconCircle(icon: CupertinoIcons.heart_fill),
                                    Spacer(),
                                    SizedBox(
                                      height: 80,
                                      width: double.infinity,
                                      child: _StatsWaveChart(),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Heart rate',
                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    Text(
                                      '120 Bpm',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Calories & Duration
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  const GlassCard(
                                    child: Row(
                                      children: [
                                        _IconCircle(icon: CupertinoIcons.flame_fill, color: Colors.orange),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Calories', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 14)),
                                              Text('143 kcal', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GlassCard(
                                    child: Row(
                                      children: [
                                        const _IconCircle(icon: CupertinoIcons.alarm),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text('Durations', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 14)),
                                              Text('130 minutes', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconCircle({required this.icon, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.black : Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBarChart extends StatelessWidget {
  const _StatsBarChart();

  @override
  Widget build(BuildContext context) {
    final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final values = [0.4, 0.7, 0.5, 0.6, 0.9, 0.6, 0.4];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (index) {
        final bool isSelected = index == 4;
        return Column(
          children: [
            Container(
              width: 40,
              height: 100 * values[index],
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D2D2D) : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
            ),
          ],
        );
      }),
    );
  }
}

class _StatsWaveChart extends StatelessWidget {
  const _StatsWaveChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavePainter(),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [Colors.white.withOpacity(0.2), Colors.transparent],
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.4, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.2, size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.2), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.2), 2, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
