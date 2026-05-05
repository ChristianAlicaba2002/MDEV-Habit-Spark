import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/category_model.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/category_service.dart';
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
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          child: Text(widget.userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _SearchBar(),
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

                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Categories', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            if (_selectedCategoryFilter != null)
                              GestureDetector(
                                onTap: () => setState(() => _selectedCategoryFilter = null),
                                child: Text('Clear Filter', style: GoogleFonts.outfit(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 85,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Add Category Button
                              GestureDetector(
                                onTap: _showAddCategoryModal,
                                child: Container(
                                  width: 105,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_circle_outline, color: AppColors.warning, size: 28),
                                      const SizedBox(height: 4),
                                      Text("New Category", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ...categories.map((cat) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _CategoryFilterItem(
                                  title: cat.name, 
                                  icon: cat.icon, 
                                  color: cat.color,
                                  isSelected: _selectedCategoryFilter == cat.name,
                                  onTap: () => setState(() => _selectedCategoryFilter = _selectedCategoryFilter == cat.name ? null : cat.name),
                                ),
                              )).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active / Filtered Habits
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategoryFilter == null ? 'My Active Habits' : '$_selectedCategoryFilter Habits', 
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 16),
                        if (categoryHabits.isEmpty)
                          _EmptyStateReminder(
                            message: _selectedCategoryFilter == null 
                              ? "No active habits found. Let's create one!" 
                              : "No habits found in $_selectedCategoryFilter. Try adding a new habit!",
                            icon: CupertinoIcons.sparkles,
                          )
                        else
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: categoryHabits.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final habit = categoryHabits[index];
                                final cat = categories.firstWhere((c) => c.name == habit.category, orElse: () => CategoryModel(id: '', name: 'General', iconCode: '58713', colorValue: 0xFFFFC107, userId: ''));
                                return _CircularHabitCard(
                                  title: habit.name,
                                  value: habit.isDone ? '1' : '0',
                                  total: '1',
                                  unit: 'done',
                                  icon: habit.icon != null && habit.icon!.isNotEmpty
                                    ? IconData(int.parse(habit.icon!), fontFamily: 'MaterialIcons') 
                                    : Icons.check,
                                  color: cat.color,
                                  progress: habit.isDone ? 1.0 : 0.0,
                                );
                              },
                            ),
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

class _CategoryFilterItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 85,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E2E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : color.withOpacity(0.7), size: 22),
            const SizedBox(height: 6),
            Text(
              title, 
              style: GoogleFonts.outfit(
                color: isSelected ? color : Colors.white, 
                fontSize: 12, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold
              )
            ),
          ],
        ),
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

class _CreateHabitModalState extends State<_CreateHabitModal> {
  final _nameController = TextEditingController();
  late String _selectedCategory;
  String _selectedRoutine = 'Morning';
  String _selectedFrequency = 'Daily';
  int _targetGoal = 3;
  IconData _selectedIcon = Icons.book;
  
  final List<IconData> _icons = [
    Icons.book, Icons.water_drop, Icons.spa, Icons.fitness_center,
    Icons.work, Icons.nightlight_round, Icons.menu_book, Icons.self_improvement
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first.name : 'General';
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
                  Text("Create Custom Habit", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Habit Name", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
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
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon ? AppColors.warning.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selectedIcon == icon ? AppColors.warning : Colors.transparent),
                      ),
                      child: Icon(icon, color: _selectedIcon == icon ? AppColors.warning : Colors.white70, size: 20),
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
                  width: (MediaQuery.of(context).size.width - 64) / 2, // 2 items per row
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
                    if (_nameController.text.isNotEmpty) {
                      await widget.habitService.addHabit(
                        widget.userId,
                        _nameController.text,
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
                  child: Text("Save Habit (CREATE)", style: GoogleFonts.outfit(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final bool hasNotification;
  const _HeaderIcon({required this.icon, this.hasNotification = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        if (hasNotification)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.secondaryLight, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(CupertinoIcons.search, color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
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
