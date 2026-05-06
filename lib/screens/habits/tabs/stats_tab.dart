import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/health_service.dart';
import 'package:habit_spark/services/category_service.dart';
import 'package:habit_spark/services/session_timer_service.dart';
import 'package:habit_spark/widgets/stats/stats_header.dart';
import 'package:habit_spark/widgets/stats/trends_card.dart';
import 'package:habit_spark/widgets/stats/timer_card.dart';
import 'package:habit_spark/widgets/stats/consistency_card.dart';
import 'package:habit_spark/widgets/stats/streak_card.dart';
import 'package:habit_spark/widgets/stats/records_card.dart';
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
  String _selectedTrendsCategory = 'Fitness';
  final HealthService _healthService = HealthService();
  final CategoryService _categoryService = CategoryService();
  final SessionTimerService _timerService = SessionTimerService();
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _showCategoryPicker(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C3E3E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color.withOpacity(0.1),
                      child: Icon(cat.icon, color: cat.color, size: 20),
                    ),
                    title: Text(
                      cat.name,
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() => _selectedTrendsCategory = cat.name);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 250.0;

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
            child: Column(
              children: [
                Expanded(
                  child: _isRefreshing
                    ? const StatsSkeleton()
                    : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.warning,
                    backgroundColor: const Color(0xFF1E2E2E),
                    child: CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: StatsHeader(
                            title: "My Stats",
                            userInitial: widget.userInitial,
                          ),
                        ),
                      ),

                      // Time Selector
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: _TimeFrameSelector(
                            selected: _selectedTimeFrame,
                            onChanged: (val) => setState(() => _selectedTimeFrame = val),
                          ),
                        ),
                      ),

                      // Trends Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: GestureDetector(
                            onLongPress: () => _showCategoryPicker(categories),
                            child: TrendsCard(
                              category: _selectedTrendsCategory,
                              habits: widget.habits,
                              categories: categories,
                            ),
                          ),
                        ),
                      ),

                      // Timer & Consistency Row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TimerCard(
                                  timerService: _timerService,
                                  height: cardHeight,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ConsistencyCard(
                                  habits: widget.habits,
                                  height: cardHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Streak & Records Row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: StreakCard(
                                  streakService: widget.streakService,
                                  userId: widget.userId,
                                  height: cardHeight,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: RecordsCard(
                                  healthService: _healthService,
                                  height: cardHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimeFrameSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TimeFrameSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: ['Week', 'Month', 'Year'].map((time) {
          bool isSelected = selected == time;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(time),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
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
    );
  }
}
