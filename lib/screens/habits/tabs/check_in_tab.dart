import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/category_service.dart';
import 'package:habit_spark/services/health_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

class CheckInTab extends StatefulWidget {
  final List<Habit> habits;
  final String userId;
  final String userName;
  final String userInitial;
  final HabitService habitService;
  final CategoryService categoryService;

  const CheckInTab({
    super.key,
    required this.habits,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habitService,
    required this.categoryService,
  });

  @override
  State<CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<CheckInTab> {
  String? _expandedRoutine = 'Morning';
  String? _selectedCategoryFilter;
  bool _expandedActivities = false;

  @override
  void initState() {
    super.initState();
    // Seed default categories if needed
    widget.categoryService.seedDefaultCategories(widget.userId);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fitness': return AppColors.warning;
      case 'Productivity': return AppColors.info;
      case 'Wellness': return AppColors.primary;
      case 'Mindfulness': return Colors.indigoAccent;
      default: return AppColors.primary;
    }
  }

  void _showAddHabitModal(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateHabitModal(
        userId: widget.userId,
        habitService: widget.habitService,
        categories: categories,
      ),
    );
  }

  void _showAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateCategoryModal(
        userId: widget.userId,
        categoryService: widget.categoryService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allHabits = widget.habits;

    final categoryHabits = _selectedCategoryFilter == null 
        ? allHabits
        : allHabits.where((h) => h.category == _selectedCategoryFilter).toList();

    final morningHabits = allHabits.where((h) => h.routine == 'Morning').toList();
    final afternoonHabits = allHabits.where((h) => h.routine == 'Afternoon').toList();
    final eveningHabits = allHabits.where((h) => h.routine == 'Evening').toList();
    final midnightHabits = allHabits.where((h) => h.routine == 'Midnight').toList();
    final generalHabits = allHabits.where((h) => h.routine == 'General' || h.routine == '').toList();

    final healthService = HealthService();

    return StreamBuilder<List<CategoryModel>>(
      stream: widget.categoryService.getCategoriesStream(widget.userId),
      builder: (context, catSnapshot) {
        final categories = catSnapshot.data ?? [];

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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "My Habits",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _HeaderIcon(icon: CupertinoIcons.bell, hasNotification: true),
                        const SizedBox(width: 12),
                        _HeaderIcon(
                          child: Text(
                            widget.userInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Daily Tasks
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Tasks', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (allHabits.isEmpty)
                          _EmptyStateReminder(
                            message: "You don't have any daily tasks yet. Tap the button below to start your journey!",
                            icon: CupertinoIcons.list_bullet,
                          )
                        else ...[
                          if (morningHabits.isNotEmpty) ...[
                            _ExpandableRoutineCard(
                              title: 'Morning Routine',
                              habits: morningHabits,
                              isExpanded: _expandedRoutine == 'Morning',
                              onToggle: () => setState(() => _expandedRoutine = _expandedRoutine == 'Morning' ? null : 'Morning'),
                              habitService: widget.habitService,
                              userId: widget.userId,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (afternoonHabits.isNotEmpty) ...[
                            _ExpandableRoutineCard(
                              title: 'Afternoon Routine',
                              habits: afternoonHabits,
                              isExpanded: _expandedRoutine == 'Afternoon',
                              onToggle: () => setState(() => _expandedRoutine = _expandedRoutine == 'Afternoon' ? null : 'Afternoon'),
                              habitService: widget.habitService,
                              userId: widget.userId,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (eveningHabits.isNotEmpty) ...[
                            _ExpandableRoutineCard(
                              title: 'Evening Routine',
                              habits: eveningHabits,
                              isExpanded: _expandedRoutine == 'Evening',
                              onToggle: () => setState(() => _expandedRoutine = _expandedRoutine == 'Evening' ? null : 'Evening'),
                              habitService: widget.habitService,
                              userId: widget.userId,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (midnightHabits.isNotEmpty) ...[
                            _ExpandableRoutineCard(
                              title: 'Midnight Routine',
                              habits: midnightHabits,
                              isExpanded: _expandedRoutine == 'Midnight',
                              onToggle: () => setState(() => _expandedRoutine = _expandedRoutine == 'Midnight' ? null : 'Midnight'),
                              habitService: widget.habitService,
                              userId: widget.userId,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (generalHabits.isNotEmpty) ...[
                            _ExpandableRoutineCard(
                              title: 'General Tasks',
                              habits: generalHabits,
                              isExpanded: _expandedRoutine == 'General',
                              onToggle: () => setState(() => _expandedRoutine = _expandedRoutine == 'General' ? null : 'General'),
                              habitService: widget.habitService,
                              userId: widget.userId,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),

                // Categories Section
                SliverToBoxAdapter(
                  child: _CategoriesSection(
                    categories: categories,
                    selectedFilter: _selectedCategoryFilter,
                    onFilterChanged: (filter) => setState(() => _selectedCategoryFilter = filter),
                    onAddCategory: _showAddCategoryModal,
                  ),
                ),

                // My Activity Habits - Display actual activities
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Activity Habits', 
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _expandedActivities = !_expandedActivities),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _expandedActivities ? 'Collapse' : 'Expand',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _expandedActivities ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Map<String, String>>>(
                          stream: healthService.getAllActivityTypes(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return _EmptyStateReminder(
                                message: "No activities logged yet. Start tracking your activities!",
                                icon: CupertinoIcons.sparkles,
                              );
                            }

                            final activities = snapshot.data!;
                            final displayCount = _expandedActivities ? activities.length : 3;
                            final displayActivities = activities.take(displayCount).toList();
                            
                            return Column(
                              children: List.generate(
                                displayActivities.length,
                                (index) {
                                  final activity = displayActivities[index];
                                  final activityType = activity['type'] ?? '';
                                  final unit = activity['unit'] ?? '';
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _CompactActivityCard(
                                      title: activityType.toUpperCase(),
                                      unit: unit,
                                      healthService: healthService,
                                      userId: widget.userId,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Add New Habit Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                    child: GestureDetector(
                      onTap: () => _showAddHabitModal(categories),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Add New Habit',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedFilter;
  final Function(String?) onFilterChanged;
  final VoidCallback onAddCategory;

  const _CategoriesSection({
    required this.categories,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize your life, your way.',
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.pencil,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Edit',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Categories grid
          SizedBox(
            height: 215, // Reduced from 240
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Create New Category Card
                _CreateCategoryCard(onTap: onAddCategory),
                const SizedBox(width: 12),
                // Category cards
                ...categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _CategoryCard(
                    category: cat,
                    isSelected: selectedFilter == cat.name,
                    onTap: () => onFilterChanged(
                      selectedFilter == cat.name ? null : cat.name,
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tip section - Refined
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B1B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: Colors.cyanAccent.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Long press a category to reorder or customize it.',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateCategoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateCategoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: Colors.white.withOpacity(0.2),
            borderRadius: 20,
            dash: 6,
            gap: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.teal.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.plus,
                  color: Color(0xFF4ECDC4),
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'New Category',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  String _getCategoryDescription(String name) {
    switch (name) {
      case 'Fitness': return 'Move your body';
      case 'Productivity': return 'Stay focused';
      case 'Wellness': return 'Feel better';
      case 'Mindfulness': return 'Be present';
      default: return 'Stay on track';
    }
  }

  String _getCategoryStats(String name) {
    switch (name) {
      case 'Fitness': return '3 workouts';
      case 'Productivity': return '5 tasks today';
      case 'Wellness': return '2 sessions today';
      case 'Mindfulness': return '2 sessions today';
      default: return '5 tasks today';
    }
  }

  IconData _getCategoryStatsIcon(String name) {
    // Using basic Lucide icons to ensure compatibility
    switch (name) {
      case 'Fitness': return LucideIcons.flame;
      case 'Productivity': return LucideIcons.check;
      case 'Mindfulness': return LucideIcons.leaf;
      default: return LucideIcons.check;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = category.color;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? accentColor : accentColor.withOpacity(0.2),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.15),
              accentColor.withOpacity(0.05),
              Colors.black.withOpacity(0.2),
            ],
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background glow
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          CupertinoIcons.ellipsis,
                          color: Colors.white.withOpacity(0.4),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Glassmorphic Icon Container
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withOpacity(0.5),
                            accentColor.withOpacity(0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    // Name & Subtitle
                    Text(
                      category.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryDescription(category.name),
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Stats Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryStatsIcon(category.name),
                            color: accentColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _getCategoryStats(category.name),
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.dash = 5.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddCategoryButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddCategoryButton({required this.onTap});

  @override
  State<_AddCategoryButton> createState() => _AddCategoryButtonState();
}

class _AddCategoryButtonState extends State<_AddCategoryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warning.withOpacity(0.15),
                AppColors.warning.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "New",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Category",
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateReminder extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyStateReminder({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(icon, color: AppColors.warning.withOpacity(0.3), size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CreateCategoryModal extends StatefulWidget {
  final String userId;
  final CategoryService categoryService;

  const _CreateCategoryModal({required this.userId, required this.categoryService});

  @override
  State<_CreateCategoryModal> createState() => _CreateCategoryModalState();
}

class _CreateCategoryModalState extends State<_CreateCategoryModal> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.fitness_center;
  Color _selectedColor = AppColors.warning;

  final List<IconData> _icons = [
    Icons.fitness_center, Icons.work, Icons.spa, Icons.self_improvement,
    Icons.book, Icons.water_drop, Icons.restaurant, Icons.nightlight_round,
    Icons.star, Icons.favorite, Icons.pets, Icons.commute,
  ];

  final List<Color> _colors = [
    AppColors.warning, AppColors.info, AppColors.primary, Colors.orange,
    Colors.pinkAccent, Colors.purpleAccent, Colors.indigoAccent, Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("New Category", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Text("Category Name", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Health, Finance...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Text("Select Icon", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _icons.map((icon) => GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedIcon == icon ? _selectedColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedIcon == icon ? _selectedColor : Colors.transparent),
                    ),
                    child: Icon(icon, color: _selectedIcon == icon ? _selectedColor : Colors.white70, size: 24),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              Text("Select Color", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = _colors[index]),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(color: _selectedColor == _colors[index] ? Colors.white : Colors.transparent, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      await widget.categoryService.addCategory(
                        widget.userId,
                        _nameController.text,
                        '${_selectedIcon.codePoint}',
                        _selectedColor.value,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Create Category", style: GoogleFonts.outfit(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateHabitModal extends StatefulWidget {
  final String userId;
  final HabitService habitService;
  final List<CategoryModel> categories;

  const _CreateHabitModal({required this.userId, required this.habitService, required this.categories});

  @override
  State<_CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends State<_CreateHabitModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Habit form fields
  final _habitNameController = TextEditingController();
  late String _selectedCategory;
  String _selectedRoutine = 'Morning';
  int _targetGoal = 3;
  IconData _selectedIcon = Icons.book;
  
  // Activity form fields
  final _activityNameController = TextEditingController();
  String _selectedActivityUnit = 'km';
  double _activityTargetValue = 1.0;
  IconData _selectedActivityIcon = Icons.directions_run;
  late String _selectedActivityCategory;
  
  final List<IconData> _icons = [
    Icons.book, Icons.water_drop, Icons.spa, Icons.fitness_center,
    Icons.work, Icons.nightlight_round, Icons.menu_book, Icons.self_improvement
  ];

  final List<IconData> _activityIcons = [
    Icons.directions_run,
    Icons.directions_bike,
    Icons.pool,
    Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.sports_tennis,
    Icons.sports_volleyball,
    Icons.sports_gymnastics,
    Icons.sports_kabaddi,
    Icons.sports_mma,
    Icons.sports_cricket,
    Icons.sports_golf,
    Icons.sports_hockey,
    Icons.sports_martial_arts,
    Icons.sports_motorsports,
    Icons.sports_rugby,
    Icons.sports_score,
    Icons.fitness_center,
    Icons.directions_walk,
    Icons.sports_bar,
    Icons.snowboarding,
    Icons.skateboarding,
  ];

  final List<String> _units = ['km', 'kcal', 'sessions', 'minutes', 'hours', 'reps', 'sets', 'lbs'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first.name : 'General';
    _selectedActivityCategory = widget.categories.isNotEmpty ? widget.categories.first.name : 'General';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _habitNameController.dispose();
    _activityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Create New", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Text(
                        'Task',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Activity',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tab Views
              SizedBox(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Habit Tab
                    _buildHabitForm(),
                    // Activity Tab
                    _buildActivityForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Habit Name", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _habitNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write habit name...',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Text("Icon Selection", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _icons.map((icon) => GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIcon == icon ? AppColors.warning.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedIcon == icon ? AppColors.warning : Colors.transparent),
                  ),
                  child: Icon(icon, color: _selectedIcon == icon ? AppColors.warning : Colors.white70, size: 18),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text("Category", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: widget.categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedCategory == cat.name ? cat.color : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(cat.name, style: GoogleFonts.outfit(color: _selectedCategory == cat.name ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text("Routine", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Morning', 'Afternoon', 'Evening', 'Midnight'].map((rout) => SizedBox(
              width: (MediaQuery.of(context).size.width - 64) / 2,
              child: GestureDetector(
                onTap: () => setState(() => _selectedRoutine = rout),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedRoutine == rout ? AppColors.warning : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(rout, style: GoogleFonts.outfit(color: _selectedRoutine == rout ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Goal & Frequency", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("Target: $_targetGoal times / day", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.warning), onPressed: () => setState(() => _targetGoal = _targetGoal > 1 ? _targetGoal - 1 : 1)),
                  Text("$_targetGoal", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.warning), onPressed: () => setState(() => _targetGoal++)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_habitNameController.text.isNotEmpty) {
                  await widget.habitService.addHabit(
                    widget.userId,
                    _habitNameController.text,
                    icon: '${_selectedIcon.codePoint}',
                    targetValue: _targetGoal.toDouble(),
                    routine: _selectedRoutine,
                    category: _selectedCategory,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Create Habit", style: GoogleFonts.outfit(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Activity Name", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _activityNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g., Running, Swimming, Cycling...',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Text("Activity Icon", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _activityIcons.map((icon) => GestureDetector(
                onTap: () => setState(() => _selectedActivityIcon = icon),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedActivityIcon == icon ? AppColors.warning.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedActivityIcon == icon ? AppColors.warning : Colors.transparent),
                  ),
                  child: Icon(icon, color: _selectedActivityIcon == icon ? AppColors.warning : Colors.white70, size: 18),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text("Category", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: widget.categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedActivityCategory = cat.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedActivityCategory == cat.name ? cat.color : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(cat.name, style: GoogleFonts.outfit(color: _selectedActivityCategory == cat.name ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text("Unit of Measurement", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _units.map((unit) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedActivityUnit = unit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedActivityUnit == unit ? AppColors.warning : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(unit, style: GoogleFonts.outfit(color: _selectedActivityUnit == unit ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Target Value", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("${_activityTargetValue.toStringAsFixed(1)} $_selectedActivityUnit", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.warning),
                    onPressed: () => setState(() => _activityTargetValue = _activityTargetValue > 0.1 ? _activityTargetValue - 0.1 : 0.1),
                  ),
                  Text("${_activityTargetValue.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.warning),
                    onPressed: () => setState(() => _activityTargetValue += 0.1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_activityNameController.text.isNotEmpty) {
                  final healthService = HealthService();
                  await healthService.logActivity(
                    type: _activityNameController.text,
                    value: _activityTargetValue,
                    unit: _selectedActivityUnit,
                    metadata: {
                      'icon': '${_selectedActivityIcon.codePoint}',
                      'category': _selectedActivityCategory,
                    },
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Create Activity", style: GoogleFonts.outfit(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final bool hasNotification;
  const _HeaderIcon({this.icon, this.child, this.hasNotification = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 20),
          if (child != null) child!,
          if (hasNotification)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandableRoutineCard extends StatelessWidget {
  final String title;
  final List<Habit> habits;
  final bool isExpanded;
  final VoidCallback onToggle;
  final HabitService habitService;
  final String userId;

  const _ExpandableRoutineCard({
    required this.title,
    required this.habits,
    required this.isExpanded,
    required this.onToggle,
    required this.habitService,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final done = habits.where((h) => h.isDone).length;
    final total = habits.length;
    final progress = total > 0 ? done / total : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2.5,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                        ),
                      ),
                      Text('$done/$total', style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                children: habits.map((habit) => _RoutineHabitItem(
                  habit: habit,
                  onToggle: () => habitService.toggleHabit(habit.id, habit.isDone, userId),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoutineHabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;

  const _RoutineHabitItem({required this.habit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 26), // Indent
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: habit.isDone ? Colors.orangeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: habit.isDone ? Colors.orangeAccent : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: habit.isDone ? const Icon(Icons.check, color: Colors.black, size: 14) : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              habit.name,
              style: GoogleFonts.outfit(
                color: habit.isDone ? Colors.white54 : Colors.white,
                fontSize: 15,
                decoration: habit.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactActivityCard extends StatelessWidget {
  final String title;
  final String unit;
  final HealthService healthService;
  final String userId;

  const _CompactActivityCard({
    required this.title,
    required this.unit,
    required this.healthService,
    required this.userId,
  });

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'gym': return Colors.redAccent;
      case 'drinking': return Colors.cyanAccent;
      case 'biking': return Colors.greenAccent;
      case 'running': return Colors.orangeAccent;
      case 'yoga': return Colors.pinkAccent;
      case 'swimming': return Colors.blueAccent;
      case 'walking': return Colors.tealAccent;
      default: return Colors.purpleAccent;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'gym': return Icons.fitness_center;
      case 'drinking': return Icons.local_drink;
      case 'biking': return Icons.directions_bike;
      case 'running': return Icons.directions_run;
      case 'yoga': return Icons.self_improvement;
      case 'swimming': return Icons.pool;
      case 'walking': return Icons.directions_walk;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getActivityColor(title);
    final icon = _getActivityIcon(title);

    return StreamBuilder<Map<String, dynamic>>(
      stream: healthService.getActivityMonthlyStats(title.toLowerCase()),
      builder: (context, snapshot) {
        final total = snapshot.data?['total'] ?? 0.0;
        final storedUnit = snapshot.data?['unit'] ?? unit;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Icon - Compact
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              // Activity Details - Compact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Unit: $storedUnit',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withOpacity(0.5)),
                          ),
                          child: Text(
                            '${total.toStringAsFixed(1)} $storedUnit',
                            style: GoogleFonts.outfit(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityDataCard extends StatelessWidget {
  final String title;
  final String unit;
  final HealthService healthService;
  final String userId;

  const _ActivityDataCard({
    required this.title,
    required this.unit,
    required this.healthService,
    required this.userId,
  });

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'gym': return Colors.redAccent;
      case 'drinking': return Colors.cyanAccent;
      case 'biking': return Colors.greenAccent;
      case 'running': return Colors.orangeAccent;
      case 'yoga': return Colors.pinkAccent;
      case 'swimming': return Colors.blueAccent;
      case 'walking': return Colors.tealAccent;
      default: return Colors.purpleAccent;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'gym': return Icons.fitness_center;
      case 'drinking': return Icons.local_drink;
      case 'biking': return Icons.directions_bike;
      case 'running': return Icons.directions_run;
      case 'yoga': return Icons.self_improvement;
      case 'swimming': return Icons.pool;
      case 'walking': return Icons.directions_walk;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getActivityColor(title);
    final icon = _getActivityIcon(title);

    return StreamBuilder<Map<String, dynamic>>(
      stream: healthService.getActivityMonthlyStats(title.toLowerCase()),
      builder: (context, snapshot) {
        final total = snapshot.data?['total'] ?? 0.0;
        final storedUnit = snapshot.data?['unit'] ?? unit;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              // Activity Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unit: $storedUnit',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Text(
                        'Total: ${total.toStringAsFixed(1)} $storedUnit',
                        style: GoogleFonts.outfit(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Action Icon
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final String total;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;

  const _ActivityCard({
    required this.title,
    required this.value,
    required this.total,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Icon and Progress Circle
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total.isNotEmpty ? '$value/$total' : value,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          unit,
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Weekly Activity Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
                    bool done = entry.key < 4;
                    return Column(
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: done ? const Color(0xFF4ECDC4) : Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: progress > 0 ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: progress > 0 ? Colors.greenAccent : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    progress > 0 ? 'Completed' : 'Pending',
                    style: GoogleFonts.outfit(
                      color: progress > 0 ? Colors.greenAccent : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularHabitCard extends StatelessWidget {
  final String title;
  final String value;
  final String total;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;

  const _CircularHabitCard({
    required this.title,
    required this.value,
    required this.total,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 40 - 24) / 3;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(total.isNotEmpty ? '$value/$total' : value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      Text(unit, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 6)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
              bool done = entry.key < 4;
              return Column(
                children: [
                  Text(entry.value, style: const TextStyle(color: Colors.white24, fontSize: 7)),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: done ? const Color(0xFF4ECDC4) : Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
