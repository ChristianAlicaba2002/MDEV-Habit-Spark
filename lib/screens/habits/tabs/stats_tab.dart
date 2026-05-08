import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/category_service.dart';
import 'package:habit_spark/widgets/stats/stats_header.dart';
import 'package:habit_spark/widgets/stats/velocity_graph_card.dart';
import 'package:habit_spark/widgets/stats/focus_distribution_card.dart';
import 'package:habit_spark/widgets/stats/consistency_card.dart';
import 'package:habit_spark/widgets/stats/streak_card.dart';
import 'package:habit_spark/widgets/stats/routine_mastery_card.dart';
import 'package:habit_spark/widgets/stats/contribution_heatmap_card.dart';
import 'package:habit_spark/widgets/stats/today_focus_card.dart';
import 'package:habit_spark/widgets/stats/radar_chart_card.dart';
import 'package:habit_spark/widgets/skeleton_loaders.dart';
import 'package:habit_spark/constants/app_colors.dart';

class StatsTab extends StatefulWidget {
  final String userId;
  final String userName;
  final String userInitial;
  final List<Habit> habits;
  final StreakService streakService;

  const StatsTab({
    super.key,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habits,
    required this.streakService,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String _selectedTimeFrame = 'Week';
  final CategoryService _categoryService = CategoryService();
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sideCardWidth = (screenWidth - 56) / 2; // 20 padding each side + 16 spacing
    final sideCardHeight = 220.0;

    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategoriesStream(widget.userId),
      builder: (context, catSnapshot) {
        final categories = catSnapshot.data ?? [];

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C3E3E), Color(0xFF4A6666)],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.cyanAccent,
              backgroundColor: const Color(0xFF1E2E2E),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // 1. Top Header (Date & Toggle)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: StatsHeader(
                        userName: widget.userName,
                        userInitial: widget.userInitial,
                      ),
                    ),
                  ),

                  // 1. Summary Card (Today's Focus + Global Streak)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: TodayFocusCard(
                        habits: widget.habits,
                        userId: widget.userId,
                        streakService: widget.streakService,
                      ),
                    ),
                  ),

                  if (_isRefreshing)
                    const SliverStatsSkeleton()
                  else ...[
                    // 2. Card 1 (Full Width): Contribution Activity
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: ContributionHeatmapCard(
                          userId: widget.userId,
                          habits: widget.habits,
                        ),
                      ),
                    ),

                    // 3. Card 2 & 3 (Side-by-Side): Consistency & Highest Habit Streak
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: sideCardWidth,
                              height: sideCardHeight,
                              child: ConsistencyCard(
                                habits: widget.habits,
                                userId: widget.userId,
                                height: sideCardHeight,
                              ),
                            ),
                            SizedBox(
                              width: sideCardWidth,
                              height: sideCardHeight,
                              child: StreakCard(
                                userId: widget.userId,
                                habits: widget.habits,
                                height: sideCardHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Card 4 (Full Width): Focus Distribution
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: FocusDistributionCard(
                          habits: widget.habits,
                          categories: categories,
                          height: 300,
                        ),
                      ),
                    ),

                    // 5. Card 5 & 6 (Side-by-Side): Weekly Velocity & Routine Mastery
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: sideCardWidth,
                              height: sideCardHeight + 20, // Give velocity slightly more height
                              child: VelocityGraphCard(userId: widget.userId),
                            ),
                            SizedBox(
                              width: sideCardWidth,
                              height: sideCardHeight + 20,
                              child: RoutineMasteryCard(
                                habits: widget.habits,
                                height: sideCardHeight + 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 6. Card 7 (Full Width): Daily Routine Balance
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        child: RadarChartCard(
                          habits: widget.habits,
                          categories: categories,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
