import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/services/theme_service.dart';
import 'package:habit_spark/screens/misc/notifications_page.dart';
import 'package:habit_spark/screens/misc/personal_information_page.dart';
import 'package:habit_spark/screens/misc/reminder_settings_page.dart';
import 'package:habit_spark/screens/habits/habit_detail_page.dart';
import 'package:habit_spark/screens/habits/create_edit_habit_page.dart';
import 'package:habit_spark/screens/calendar/training_calendar_page.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/widgets/app_header.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';
import 'package:habit_spark/screens/habits/tabs/dashboard_tab.dart';
import 'package:habit_spark/screens/habits/tabs/check_in_tab.dart';
import 'package:habit_spark/screens/habits/tabs/stats_tab.dart';
import 'package:habit_spark/screens/habits/tabs/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final HabitService _habitService = HabitService();
  final NotificationService _notificationService = NotificationService();
  final StreakService _streakService = StreakService();

  int _selectedIndex = 0;
  final _searchController = TextEditingController(); // Added
  String _searchQuery = ''; // Added

  late AnimationController _heroAnimController;
  late AnimationController _ringAnimController;
  late Animation<double> _heroFadeAnim;
  late Animation<double> _ringProgressAnim;
  double _currentRingProgress = 0;
  Stream<List<Habit>>? _habitStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _heroAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFadeAnim = CurvedAnimation(
      parent: _heroAnimController,
      curve: Curves.easeOut,
    );
    _ringAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringProgressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ringAnimController, curve: Curves.easeInOut),
    );
    _heroAnimController.forward();
    final userId = _authService.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      _habitStream = _habitService.getHabitsStream(userId);
    }
    _initializeUserData();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Added
    _heroAnimController.dispose();
    _ringAnimController.dispose();
    super.dispose();
  }

  void _animateRing(double target) {
    _ringAnimController.reset();
    _currentRingProgress = target;
    _ringAnimController.forward();
  }

  Future<void> _initializeUserData() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      // Temporarily wipe all existing habits to clear the screen
      final habits = await FirebaseFirestore.instance
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in habits.docs) {
        await doc.reference.delete();
      }
      
      await _streakService.getUserStreak(userId);
      await _streakService.checkStreakOnLogin(userId);
    }
  }

  void _showAddHabitDialog() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreateEditHabitPage(userId: userId)),
      );
    }
  }


  String _getJoinedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<UserModel?>(
          stream: _authService.getUserDataStream(userId),
          builder: (context, userSnapshot) {
            final firstName = userSnapshot.data?.firstName ?? user?.email?.split('@')[0] ?? 'User';
            final userInitial = firstName.substring(0, 1).toUpperCase();

            return StreamBuilder<List<Habit>>(
              stream: _habitStream,
              builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _DashboardSkeleton();
            }
            if (snapshot.hasError) {
              return _ErrorView(onRetry: () => setState(() {}));
            }

            final habits = snapshot.data ?? [];
            final filteredHabits = habits
                .where((h) =>
                    h.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
            final completedCount = habits.where((h) => h.isDone == true).length;
            final totalCount = habits.length;
            final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

            // Animate ring whenever progress changes
            if (_currentRingProgress != progress) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _animateRing(progress),
              );
            }

            return IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardTab(
                  userId: userId,
                  userName: firstName,
                  userInitial: userInitial,
                  habits: filteredHabits,
                  completedCount: completedCount,
                  totalCount: totalCount,
                  progress: progress,
                  heroFadeAnim: _heroFadeAnim,
                  ringProgressAnim: _ringProgressAnim,
                  notificationService: _notificationService,
                  streakService: _streakService,
                  authService: _authService,
                  searchController: _searchController,
                  onAddHabit: _showAddHabitDialog,
                  onProfileTap: () => setState(() => _selectedIndex = 3),
                ),
                CheckInTab(
                  habits: habits,
                  userId: userId,
                  habitService: _habitService,
                  onAddHabit: _showAddHabitDialog,
                ),
                StatsTab(
                  userId: userId,
                  habits: habits,
                  streakService: _streakService,
                ),
                ProfileTab(
                  userId: userId,
                  authService: _authService,
                  streakService: _streakService,
                  habits: habits,
                  onBackTap: () => setState(() => _selectedIndex = 0),
                ),
              ],
            );
          },
        );
      },
    ),
  ),
  floatingActionButton: null,
  bottomNavigationBar: _BottomNav(
    selectedIndex: _selectedIndex,
    onTap: (i) => setState(() => _selectedIndex = i),
  ),
);
  }
}

// â”€â”€â”€ Bottom Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1F1F),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavItem(
                      icon: CupertinoIcons.house,
                      activeIcon: CupertinoIcons.house_fill,
                      label: 'Home',
                      selected: selectedIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.checkmark_square,
                      activeIcon: CupertinoIcons.checkmark_square_fill,
                      label: 'Habits',
                      selected: selectedIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.chart_bar,
                      activeIcon: CupertinoIcons.chart_bar_fill,
                      label: 'Stats',
                      selected: selectedIndex == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.person,
                      activeIcon: CupertinoIcons.person_fill,
                      label: 'Profile',
                      selected: selectedIndex == 3,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: selected ? null : Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 24,
              color: selected ? const Color(0xFF0A1F1F) : Colors.white,
            ),
            if (selected) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0A1F1F),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Error View â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: AppUIComponents.primaryButtonStyle,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Skeleton (App Bar)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  _SkeletonBlock(width: 44, height: 44, shape: BoxShape.circle),
                ],
              ),
            ),
            
            // Greeting & Date Skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBlock(width: 250, height: 32),
                  SizedBox(height: 12),
                  _SkeletonBlock(width: 150, height: 16),
                ],
              ),
            ),
            
            // Search Bar Skeleton
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _SkeletonBlock(width: double.infinity, height: 60, borderRadius: 35),
            ),
            
            // Today's Stats Header Skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _SkeletonBlock(width: 120, height: 24),
                  _SkeletonBlock(width: 60, height: 16),
                ],
              ),
            ),
            
            // Health Stat Cards (Horizontal List) Skeleton
            SizedBox(
              height: 160,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _SkeletonBlock(width: 160, height: 160, borderRadius: 30),
                  SizedBox(width: 16),
                  _SkeletonBlock(width: 160, height: 160, borderRadius: 30),
                  SizedBox(width: 16),
                  _SkeletonBlock(width: 160, height: 160, borderRadius: 30),
                ],
              ),
            ),
            
            // Today's Workout Header Skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _SkeletonBlock(width: 150, height: 24),
                  _SkeletonBlock(width: 60, height: 16),
                ],
              ),
            ),
            
            // Large Workout Card Skeleton
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _SkeletonBlock(width: double.infinity, height: 240, borderRadius: 35),
            ),
            
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}
