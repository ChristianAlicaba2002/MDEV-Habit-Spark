import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
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
      await _habitService.seedDefaultHabits(userId);
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
    final userName = user?.email?.split('@')[0] ?? 'User';
    final userInitial = user?.email?.substring(0, 1).toUpperCase() ?? 'U';

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Habit>>(
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
                _DashboardTab(
                  userId: userId,
                  userName: userName,
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
                _CheckInTab(
                  habits: habits,
                  userId: userId,
                  habitService: _habitService,
                  onAddHabit: _showAddHabitDialog,
                ),
                _StatsTab(
                  userId: userId,
                  habits: habits,
                  streakService: _streakService,
                ),
                _ProfileTab(
                  userId: userId,
                  authService: _authService,
                  streakService: _streakService,
                  habits: habits,
                  onBackTap: () => setState(() => _selectedIndex = 0),
                ),
              ],
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

// ─── Bottom Navigation ────────────────────────────────────────────────────────

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
          height: 70,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(35),
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
                      icon: CupertinoIcons.bolt,
                      activeIcon: CupertinoIcons.bolt_fill,
                      label: 'Activity',
                      selected: selectedIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.play_fill,
                      activeIcon: CupertinoIcons.play_fill,
                      label: 'Record',
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
        height: 54,
        padding: EdgeInsets.only(
          left: selected ? 18 : 0,
          right: 0,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.white.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 20,
                color: selected ? Colors.black : Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

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

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final String userId;
  final String userName;
  final String userInitial;
  final List<Habit> habits;
  final int completedCount;
  final int totalCount;
  final double progress;
  final Animation<double> heroFadeAnim;
  final Animation<double> ringProgressAnim;
  final NotificationService notificationService;
  final StreakService streakService;
  final AuthService authService;
  final TextEditingController searchController; // Added
  final VoidCallback onAddHabit;
  final VoidCallback onProfileTap;

  const _DashboardTab({
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habits,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.heroFadeAnim,
    required this.ringProgressAnim,
    required this.notificationService,
    required this.streakService,
    required this.authService,
    required this.searchController, // Added
    required this.onAddHabit,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: StreamBuilder<int>(
              stream: notificationService.getUnreadCountStream(userId),
              builder: (context, notifSnap) {
                final unreadCount = notifSnap.data ?? 0;
                return StreamBuilder<UserModel?>(
                  stream: authService.getUserDataStream(userId),
                  builder: (context, userSnap) {
                    return AppHeader(
                      onNotificationTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      ),
                      onProfileTap: onProfileTap,
                      notificationCount: unreadCount,
                      userInitial: (userSnap.data?.firstName != null &&
                              userSnap.data!.firstName.isNotEmpty)
                          ? userSnap.data!.firstName[0].toUpperCase()
                          : userInitial,
                      photoUrl: userSnap.data?.photoUrl,
                      userName: userSnap.data?.firstName ?? userName,
                      progress: progress,
                    );
                  },
                );
              },
            ),
          ),
        ),

        // ── Motivational Hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preparing',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'for the big move.',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAddHabit,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: Colors.white.withOpacity(0.35),
                      size: 22,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withAlpha(100),
                              size: 20,
                            ),
                            onPressed: () => searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Goal Crusher Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Habits",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "View all",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Goal Crusher Horizontal List
        SliverToBoxAdapter(
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _GoalCrusherCard(
                  habit: habit,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailPage(habit: habit),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Recent Activities Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Activities",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "View all",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Recent Activities List
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const _RecentActivityCard(
                  title: 'Ran',
                  subtitle: 'Today',
                  value1: '8.8km',
                  value2: '45:32',
                  icon: Icons.directions_run,
                ),
                const SizedBox(height: 12),
                const _RecentActivityCard(
                  title: 'Cycle',
                  subtitle: 'Yesterday',
                  value1: '24.5km',
                  value2: '1:12:15',
                  icon: Icons.directions_bike,
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String userName;
  final int completedCount;
  final int totalCount;
  final double progress;
  final Animation<double> ringProgressAnim;
  final StreakService streakService;
  final String userId;

  const _HeroBanner({
    required this.userName,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.ringProgressAnim,
    required this.streakService,
    required this.userId,
  });

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getMotivation(double progress) {
    if (progress == 0) return 'Let\'s crush it today! 💪';
    if (progress < 0.4) return 'Great start! Keep going! 🔥';
    if (progress < 0.7) return 'You\'re on fire! 🚀';
    if (progress < 1.0) return 'Almost there! Push harder!';
    return 'Perfect day! You\'re unstoppable! 🏆';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Greeting + Motivation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getMotivation(progress),
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13,
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

// ─── Activity Ring ────────────────────────────────────────────────────────────

class _ActivityRing extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final Animation<double> animation;

  const _ActivityRing({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final animatedProgress = animation.value * progress;
        return SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(100, 100),
                painter: _RingPainter(
                  progress: animatedProgress,
                  backgroundColor: AppColors.surfaceAlt,
                  foregroundColor: AppColors.primary,
                  strokeWidth: 10,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(animatedProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: TextStyle(
                      color: Colors.white.withAlpha(160),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final fgPaint = Paint()
        ..shader = LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress;
}

// ─── Quick Stats Row ──────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final StreakService streakService;
  final String userId;
  final int completedCount;
  final int totalCount;

  const _QuickStatsRow({
    required this.streakService,
    required this.userId,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: streakService.getStreakStream(userId),
      builder: (context, snapshot) {
        final streakData = snapshot.data ?? {};
        final currentStreak = streakData['currentStreak'] ?? 0;
        final longestStreak = streakData['longestStreak'] ?? 0;
        final completionRate = totalCount > 0
            ? ((completedCount / totalCount) * 100).toInt()
            : 0;

        return Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.local_fire_department,
                iconColor: const Color(0xFFFF6B6B),
                label: 'Streak',
                value: '$currentStreak d',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatChip(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFD93D),
                label: 'Best',
                value: '$longestStreak d',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatChip(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primary,
                label: 'Rate',
                value: '$completionRate%',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Goal Crusher Card ────────────────────────────────────────────────────────
class _GoalCrusherCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const _GoalCrusherCard({required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine info based on habit name or type
    String mainValue = "0";
    String title = habit.name;
    String subtext = "0%";
    IconData ringIcon = Icons.fitness_center;
    Color ringColor = AppColors.primary;

    if (habit.name.toLowerCase().contains('run') ||
        habit.name.toLowerCase().contains('walk')) {
      mainValue = "42.2 km";
      title = "This Week";
      subtext = "12%";
      ringIcon = Icons.directions_run;
      ringColor = const Color(0xFF4ECDC4);
    } else if (habit.name.toLowerCase().contains('streak')) {
      mainValue = "7 Days";
      title = "Streak";
      subtext = "Keep it up!";
      ringIcon = Icons.local_fire_department;
      ringColor = const Color(0xFFFF6B6B);
    } else {
      mainValue = habit.isDone ? "1" : "0";
      title = habit.name;
      subtext = habit.isDone ? "100%" : "0%";
      ringIcon = Icons.check_circle_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mainValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtext,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                      ),
                    ),
                    Icon(
                      ringIcon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Activity Card ─────────────────────────────────────────────────────

class _RecentActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value1;
  final String value2;
  final IconData icon;

  const _RecentActivityCard({
    required this.title,
    required this.subtitle,
    required this.value1,
    required this.value2,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty Habits State ───────────────────────────────────────────────────────

class _EmptyHabitsState extends StatelessWidget {
  final VoidCallback onAddHabit;
  const _EmptyHabitsState({required this.onAddHabit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No habits yet',
          style: AppTextStyles.heading4,
        ),
        const SizedBox(height: 8),
        Text(
          'Start building your fitness routine\nby adding your first habit',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onAddHabit,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add First Habit',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Check-In Tab ─────────────────────────────────────────────────────────────

class _CheckInTab extends StatefulWidget {
  final List<Habit> habits;
  final String userId;
  final HabitService habitService;
  final VoidCallback onAddHabit;

  const _CheckInTab({
    required this.habits,
    required this.userId,
    required this.habitService,
    required this.onAddHabit,
  });

  @override
  State<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<_CheckInTab> {
  @override
  Widget build(BuildContext context) {
    final habits = widget.habits;
    final completed = habits.where((h) => h.isDone).length;
    final total = habits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text('Activity', style: AppTextStyles.heading3),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onAddHabit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Progress Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _CheckInProgressCard(
              completed: completed,
              total: total,
              progress: progress,
            ),
          ),
        ),

        // Habit List
        habits.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.checklist_rounded,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No habits to check in',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: widget.onAddHabit,
                        child: Text(
                          'Add your first habit →',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _CheckInHabitCard(
                      habit: habits[index],
                      userId: widget.userId,
                      habitService: widget.habitService,
                      onEditTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateEditHabitPage(
                            habit: habits[index],
                            userId: widget.userId,
                          ),
                        ),
                      ),
                      onDeleteTap: () => _confirmDelete(habits[index]),
                    ),
                    childCount: habits.length,
                  ),
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  void _confirmDelete(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Habit?', style: AppTextStyles.heading4),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.habitService.deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _CheckInProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();
    final Color barColor = pct >= 80
        ? AppColors.success
        : pct >= 50
            ? AppColors.warning
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            barColor.withAlpha(30),
            barColor.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: barColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Progress",
                    style: AppTextStyles.heading5,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completed of $total habits done',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: barColor.withAlpha(30),
                  border: Border.all(color: barColor.withAlpha(80), width: 2),
                ),
                child: Center(
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      color: barColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              builder: (context, val, child) => LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInHabitCard extends StatefulWidget {
  final Habit habit;
  final String userId;
  final HabitService habitService;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const _CheckInHabitCard({
    required this.habit,
    required this.userId,
    required this.habitService,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  State<_CheckInHabitCard> createState() => _CheckInHabitCardState();
}

class _CheckInHabitCardState extends State<_CheckInHabitCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDone = widget.habit.isDone;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF1E2E1E) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? AppColors.success.withAlpha(80)
                : AppColors.border.withAlpha(80),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () async {
                      await widget.habitService.toggleHabit(
                        widget.habit.id,
                        widget.habit.isDone,
                        widget.userId,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.success : Colors.transparent,
                        border: Border.all(
                          color: isDone
                              ? AppColors.success
                              : AppColors.textSecondary,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style: AppTextStyles.heading5.copyWith(
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: isDone
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isDone ? 'Completed ✓' : 'Tap checkbox to complete',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDone
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Expanded actions
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Row(
                        children: [
                          _ActionBtn(
                            label: 'Edit',
                            icon: Icons.edit_outlined,
                            color: AppColors.primary,
                            onTap: widget.onEditTap,
                          ),
                          const SizedBox(width: 8),
                          _ActionBtn(
                            label: 'Delete',
                            icon: Icons.delete_outline,
                            color: AppColors.error,
                            onTap: widget.onDeleteTap,
                          ),
                          const SizedBox(width: 8),
                          _ActionBtn(
                            label: 'Details',
                            icon: Icons.info_outline,
                            color: AppColors.accent,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HabitDetailPage(habit: widget.habit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Record Tab ───────────────────────────────────────────────────────────────

class _StatsTab extends StatefulWidget {
  final String userId;
  final List<Habit> habits;
  final StreakService streakService;

  const _StatsTab({
    required this.userId,
    required this.habits,
    required this.streakService,
  });

  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  bool _isTracking = false;
  double _distance = 0.0;
  int _duration = 0; // in seconds
  double _pace = 0.0;
  int _calories = 0;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  void _toggleTracking() {
    setState(() {
      if (_isTracking) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      _startTimer();
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isTracking && mounted) {
        setState(() {
          _duration = _stopwatch.elapsed.inSeconds;
          // Simulate distance increase (0.1 km per 10 seconds)
          _distance = (_duration / 10) * 0.1;
          // Calculate pace (km/h)
          if (_duration > 0) {
            _pace = (_distance / (_duration / 3600)).isFinite
                ? _distance / (_duration / 3600)
                : 0.0;
            // Calculate calories (rough estimate: 60 calories per km)
            _calories = (_distance * 60).toInt();
          }
        });
        _startTimer();
      }
    });
  }

  void _resetTracking() {
    setState(() {
      _stopwatch.reset();
      _isTracking = false;
      _distance = 0.0;
      _duration = 0;
      _pace = 0.0;
      _calories = 0;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: const Center(
              child: Text('Record', style: AppTextStyles.heading3),
            ),
          ),
        ),

        // Running Workout Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Background image - running man
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/Running.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  // Dark overlay gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withAlpha(120),
                            Colors.black.withAlpha(60),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Running',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Go',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

        // Jogging Workout Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Background image - jogging
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/Jogging.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  // Dark overlay gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withAlpha(120),
                            Colors.black.withAlpha(60),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Jogging',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Go',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
      ],
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}

// ── Stat Card Widget ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map Painter ───────────────────────────────────────────────────────────────

class RunningFigurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 6, fillPaint);

    // Body
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.22),
      Offset(size.width * 0.5, size.height * 0.45),
      paint,
    );

    // Left arm (back, extended)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.28),
      Offset(size.width * 0.3, size.height * 0.35),
      paint,
    );

    // Right arm (forward, bent)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.28),
      Offset(size.width * 0.65, size.height * 0.22),
      paint,
    );

    // Left leg (forward, bent)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.7),
      paint,
    );

    // Right leg (back, extended)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.35, size.height * 0.65),
      paint,
    );

    // Motion lines to show running
    final motionPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Motion line 1
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.05, size.height * 0.5),
      motionPaint,
    );

    // Motion line 2
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.65),
      Offset(size.width * 0.05, size.height * 0.65),
      motionPaint,
    );
  }

  @override
  bool shouldRepaint(RunningFigurePainter oldDelegate) => false;
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw wavy lines to simulate map
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(path, paint);

    // Draw more lines
    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.65,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.75,
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(path2, paint);

    // Draw vertical lines
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.35, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.65, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => false;
}

// ─── Profile Tab ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final String userId;
  final AuthService authService;
  final StreakService streakService;
  final List<Habit> habits;
  final VoidCallback onBackTap;

  const _ProfileTab({
    required this.userId,
    required this.authService,
    required this.streakService,
    required this.habits,
    required this.onBackTap,
  });

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
    final completedCount = habits.where((h) => h.isDone).length;
    final totalCount = habits.length;
    final completionRate = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return StreamBuilder<UserModel?>(
      stream: authService.getUserDataStream(userId),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final user = authService.currentUser;
        final displayName =
            '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'.trim();
        final name = displayName.isEmpty
            ? user?.email?.split('@')[0] ?? 'User'
            : displayName;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Custom Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundIconButton(
                      icon: CupertinoIcons.arrow_left,
                      onTap: onBackTap,
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      color: const Color(0xFF1A1A1A),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withAlpha(20)),
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Show settings',
                      child: const _RoundIconButton(
                        icon: CupertinoIcons.settings,
                        onTap: null, // Transparent to PopupMenuButton
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Edit Profile — Coming soon')),
                          );
                        } else if (value == 'logout') {
                          authService.signOut();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          height: 40,
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          height: 40,
                          child: Text(
                            'Log out',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Profile Card (avatar + name + location + stats) — single container
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Builder(builder: (context) {
                  // Calculate age from birthDate if available
                  String ageStr = '--';
                  if (userData?.birthDate != null &&
                      userData!.birthDate.isNotEmpty) {
                    try {
                      final parts = userData!.birthDate.split('-');
                      if (parts.length == 3) {
                        final dob = DateTime(
                          int.parse(parts[0]),
                          int.parse(parts[1]),
                          int.parse(parts[2]),
                        );
                        final now = DateTime.now();
                        int age = now.year - dob.year;
                        if (now.month < dob.month ||
                            (now.month == dob.month && now.day < dob.day)) {
                          age--;
                        }
                        ageStr = '$age';
                      }
                    } catch (_) {}
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // ── Top: avatar + name + location
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFF3A3A3C),
                              backgroundImage: (userData?.photoUrl != null &&
                                      userData!.photoUrl.isNotEmpty)
                                  ? NetworkImage(userData!.photoUrl)
                                  : null,
                              child: (userData?.photoUrl == null ||
                                      userData!.photoUrl.isEmpty)
                                  ? Text(
                                      (user?.email
                                              ?.substring(0, 1)
                                              .toUpperCase()) ??
                                          'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.location_solid,
                                      size: 13,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      userData?.email.isNotEmpty == true
                                          ? userData!.email.split('@')[0]
                                          : 'Location not set',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Bottom: Age / Height / Weight
                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStatBox(
                                label: 'Age',
                                value: userData?.age != null ? '${userData!.age}' : ageStr,
                                unit: 'y.o',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ProfileStatBox(
                                label: 'Height',
                                value: userData?.height != null ? '${userData!.height!.toInt()}' : '--',
                                unit: 'cm',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ProfileStatBox(
                                label: 'Weight',
                                value: userData?.weight != null ? '${userData!.weight!.toInt()}' : '--',
                                unit: 'kg',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // ── Account Settings Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'Account settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Tracking Stats Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: [
                        _TrackingCard(
                          title: 'Total Distance',
                          value: '${(habits.length * 2.5).toStringAsFixed(1)} km',
                          icon: CupertinoIcons.arrow_up_right,
                        ),
                        _TrackingCard(
                          title: 'Total Activities',
                          value: '${habits.length}',
                          icon: CupertinoIcons.calendar,
                        ),
                        _TrackingCard(
                          title: 'Monthly Goal',
                          value: '${(completionRate * 100).toStringAsFixed(0)}%',
                          icon: CupertinoIcons.checkmark_circle,
                        ),
                        _TrackingCard(
                          title: 'Achievements',
                          value: '${completedCount}',
                          icon: CupertinoIcons.star_fill,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Account Settings Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Account settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Settings Items
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.person,
                        label: 'Personal Information',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PersonalInformationPage(
                              userId: userId,
                              authService: authService,
                              initialData: userData,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withAlpha(15), indent: 56, endIndent: 16),
                      _SettingsRow(
                        icon: CupertinoIcons.bell,
                        label: 'Reminder',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReminderSettingsPage(
                              userId: userId,
                              habitId: 'general',
                              habitName: 'General Reminders',
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withAlpha(15), indent: 56, endIndent: 16),
                      const _SettingsThemeRow(),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TrackingCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Profile Stat Box ──────────────────────────────────────────────────────────

class _ProfileStatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _ProfileStatBox({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '  $unit',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

// ── Settings Row ──────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.grey[400], size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Settings Theme Row (with toggle) ─────────────────────────────────────────

class _SettingsThemeRow extends StatefulWidget {
  const _SettingsThemeRow();

  @override
  State<_SettingsThemeRow> createState() => _SettingsThemeRowState();
}

class _SettingsThemeRowState extends State<_SettingsThemeRow> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(CupertinoIcons.moon_fill, color: Colors.grey[400], size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoSwitch(
            value: _isDarkMode,
            activeColor: Colors.grey[600]!,
            onChanged: (val) => setState(() => _isDarkMode = val),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textSecondary.withAlpha(100),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton Loading ────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: Column(
        children: [
          // Header Skeleton
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: _HeaderSkeleton(),
          ),
          const SizedBox(height: 24),
          // Motivational Text Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonBlock(width: 200, height: 32),
                SizedBox(height: 8),
                _SkeletonBlock(width: 150, height: 32),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Search Bar Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child:
                _SkeletonBlock(width: double.infinity, height: 50, borderRadius: 25),
          ),
          const SizedBox(height: 32),
          // Section Header Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SkeletonBlock(width: 120, height: 24),
                _SkeletonBlock(width: 60, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Habit Grid Skeleton
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const _SkeletonBlock(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _SkeletonBlock(width: 54, height: 54, shape: BoxShape.circle),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SkeletonBlock(width: 120, height: 20),
            SizedBox(height: 8),
            _SkeletonBlock(width: 80, height: 14),
          ],
        ),
        const Spacer(),
        const _SkeletonBlock(width: 40, height: 40, shape: BoxShape.circle),
      ],
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
