import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/screens/notifications_page.dart';
import 'package:habit_spark/screens/habit_detail_page.dart';
import 'package:habit_spark/screens/create_edit_habit_page.dart';
import 'package:habit_spark/screens/training_calendar_page.dart';
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
  late AnimationController _heroAnimController;
  late AnimationController _ringAnimController;
  late Animation<double> _heroFadeAnim;
  late Animation<double> _ringProgressAnim;
  double _currentRingProgress = 0;

  @override
  void initState() {
    super.initState();
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
    _initializeUserData();
  }

  @override
  void dispose() {
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
          stream: _habitService.getHabitsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return _ErrorView(onRetry: () => setState(() {}));
            }

            final habits = snapshot.data ?? [];
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
                  habits: habits,
                  completedCount: completedCount,
                  totalCount: totalCount,
                  progress: progress,
                  heroFadeAnim: _heroFadeAnim,
                  ringProgressAnim: _ringProgressAnim,
                  notificationService: _notificationService,
                  streakService: _streakService,
                  authService: _authService,
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
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 1)
          ? FloatingActionButton(
              onPressed: _showAddHabitDialog,
              backgroundColor: AppColors.primary,
              elevation: 6,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
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
                      icon: CupertinoIcons.checkmark_square,
                      activeIcon: CupertinoIcons.checkmark_square_fill,
                      label: 'Check-In',
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
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Excellence is not an act,',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'but a habit.',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAddHabit,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E), // Near black
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
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
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.search,
                    color: Colors.white.withAlpha(100),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Goal Crusher Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Goal Crusher",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "View all",
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Habit Grid
        habits.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: _EmptyHabitsState(onAddHabit: onAddHabit),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habits[index];
                      return _HabitGridCard(
                        habit: habit,
                        index: index,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HabitDetailPage(habit: habit),
                          ),
                        ),
                      );
                    },
                    childCount: habits.length,
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

// ─── Habit Grid Card ──────────────────────────────────────────────────────────

class _HabitGridCard extends StatelessWidget {
  final Habit habit;
  final int index;
  final VoidCallback onTap;

  const _HabitGridCard({
    required this.habit,
    required this.index,
    required this.onTap,
  });

  static const _gradients = [
    [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
    [Color(0xFFFF9A56), Color(0xFFFF6A88)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  ];

  IconData _getHabitIcon() {
    if (habit.icon != null) return _iconFromString(habit.icon!);
    final name = habit.name.toLowerCase();
    if (name.contains('run') || name.contains('jog')) return Icons.directions_run;
    if (name.contains('read')) return Icons.menu_book;
    if (name.contains('water') || name.contains('drink')) return Icons.water_drop;
    if (name.contains('exercise') || name.contains('workout')) return Icons.fitness_center;
    if (name.contains('meditat') || name.contains('yoga')) return Icons.self_improvement;
    if (name.contains('sleep')) return Icons.bedtime;
    if (name.contains('eat') || name.contains('meal')) return Icons.restaurant;
    if (name.contains('study') || name.contains('learn')) return Icons.school;
    if (name.contains('walk')) return Icons.directions_walk;
    return Icons.check_circle_outline;
  }

  IconData _iconFromString(String s) {
    const map = {
      'directions_run': Icons.directions_run,
      'fitness_center': Icons.fitness_center,
      'self_improvement': Icons.self_improvement,
      'menu_book': Icons.menu_book,
      'water_drop': Icons.water_drop,
      'restaurant': Icons.restaurant,
      'bedtime': Icons.bedtime,
      'school': Icons.school,
      'code': Icons.code,
      'music_note': Icons.music_note,
      'brush': Icons.brush,
      'camera_alt': Icons.camera_alt,
      'favorite': Icons.favorite,
      'wb_sunny': Icons.wb_sunny,
      'nightlight': Icons.nightlight,
      'local_cafe': Icons.local_cafe,
    };
    return map[s] ?? Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final colors = habit.isDone
        ? [const Color(0xFF3A3A3A), const Color(0xFF2A2A2A)]
        : _gradients[index % _gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors[0].withAlpha(habit.isDone ? 20 : 80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  _getHabitIcon(),
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(_getHabitIcon(), color: Colors.white, size: 20),
                      if (habit.isDone)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    habit.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.isDone ? 'Done ✓' : 'Pending',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Check-In', style: AppTextStyles.heading3),
                GestureDetector(
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

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  final String userId;
  final List<Habit> habits;
  final StreakService streakService;

  const _StatsTab({
    required this.userId,
    required this.habits,
    required this.streakService,
  });

  @override
  Widget build(BuildContext context) {
    final completed = habits.where((h) => h.isDone).length;
    final total = habits.length;
    final rate = total > 0 ? ((completed / total) * 100).toInt() : 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Title
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('Progress Analytics', style: AppTextStyles.heading2),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              'Keep pushing your limits every day',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),

        // Streak Cards
        SliverToBoxAdapter(
          child: StreamBuilder<Map<String, dynamic>>(
            stream: streakService.getStreakStream(userId),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              final current = data['currentStreak'] ?? 0;
              final longest = data['longestStreak'] ?? 0;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Current Streak',
                        value: '$current',
                        unit: 'days',
                        icon: Icons.local_fire_department,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Longest Streak',
                        value: '$longest',
                        unit: 'days',
                        icon: Icons.emoji_events,
                        color: const Color(0xFFFFD93D),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Habit stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _AnalyticsCard(
                    title: 'Total Habits',
                    value: '$total',
                    unit: 'habits',
                    icon: Icons.list_alt,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnalyticsCard(
                    title: "Today's Rate",
                    value: '$rate%',
                    unit: 'completed',
                    icon: Icons.trending_up,
                    color: const Color(0xFF95E1D3),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Weekly Bar Chart
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text('This Week', style: AppTextStyles.heading4),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WeeklyBarChart(userId: userId),
          ),
        ),

        // Habits breakdown carousel
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text('Habits Breakdown', style: AppTextStyles.heading4),
          ),
        ),
        SliverToBoxAdapter(
          child: _HabitsCarousel(
            habits: habits,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly Bar Chart ─────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatefulWidget {
  final String userId;
  const _WeeklyBarChart({required this.userId});

  @override
  State<_WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<_WeeklyBarChart> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekDays.asMap().entries.map((e) {
              final idx = e.key;
              final day = e.value;
              final isToday = day.day == now.day && day.month == now.month;
              final isSelected = _selectedDay == idx;
              final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final dayName = dayNames[day.weekday - 1];

              // Simulated fill heights based on weekday (replace with real data later)
              final fillHeights = [0.7, 0.5, 0.9, 0.4, 0.8, 0.3, isToday ? 0.6 : 0.2];
              final fill = fillHeights[idx];
              final barColor = isToday || isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary.withAlpha(80);

              return GestureDetector(
                onTap: () => setState(
                  () => _selectedDay = _selectedDay == idx ? null : idx,
                ),
                child: Column(
                  children: [
                    // Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 32,
                      height: 80,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        width: 18,
                        height: 80 * fill,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Day bubble
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isToday || isSelected)
                            ? AppColors.primary.withAlpha(30)
                            : Colors.transparent,
                        border: (isToday || isSelected)
                            ? Border.all(
                                color: AppColors.primary.withAlpha(100))
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              color: (isToday || isSelected)
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: (isToday || isSelected)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Habits Carousel ──────────────────────────────────────────────────────────

class _HabitsCarousel extends StatefulWidget {
  final List<Habit> habits;
  const _HabitsCarousel({required this.habits});

  @override
  State<_HabitsCarousel> createState() => _HabitsCarouselState();
}

class _HabitsCarouselState extends State<_HabitsCarousel> {
  late PageController _controller;
  int _current = 0;

  static const _gradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF4ECDC4), Color(0xFF2A9D8F)],
    [Color(0xFFFFD93D), Color(0xFFFFC300)],
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    [Color(0xFFFF6B9D), Color(0xFFC44569)],
    [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = widget.habits;

    if (habits.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withAlpha(80)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.insights, size: 48, color: AppColors.textSecondary),
              SizedBox(height: 12),
              Text('No habits yet', style: AppTextStyles.heading5),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: habits.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              final habit = habits[i];
              final grad = _gradients[i % _gradients.length];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailPage(habit: habit),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 20 : 8,
                    right: i == habits.length - 1 ? 20 : 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: grad,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: grad[0].withAlpha(80),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                habit.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  habit.isDone
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.isDone
                                    ? '✅ Completed today!'
                                    : '⏳ Not done yet',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(220),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to view details',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(habits.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _current == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _current == i
                    ? AppColors.primary
                    : AppColors.textSecondary.withAlpha(77),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
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

            // ── Avatar Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(20),
                          width: 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.surface,
                        backgroundImage: (userData?.photoUrl != null &&
                                userData!.photoUrl.isNotEmpty)
                            ? NetworkImage(userData!.photoUrl)
                            : null,
                        child: (userData?.photoUrl == null ||
                                userData!.photoUrl.isEmpty)
                            ? Text(
                                user?.email
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tracking Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'Tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Tracking Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: StreamBuilder<Map<String, dynamic>>(
                stream: streakService.getStreakStream(userId),
                builder: (context, streakSnap) {
                  final streakData = streakSnap.data ?? {};
                  final currentStreak = streakData['currentStreak'] ?? 0;
                  final longestStreak = streakData['longestStreak'] ?? 0;

                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildListDelegate([
                      _TrackingCard(
                        title: 'Today\'s Progress',
                        value: '${(completionRate * 100).toInt()}%',
                        icon: CupertinoIcons.chart_bar,
                      ),
                      _TrackingCard(
                        title: 'Total Activities',
                        value: '$totalCount',
                        icon: CupertinoIcons.calendar,
                      ),
                      _TrackingCard(
                        title: 'Current Streak',
                        value: '$currentStreak days',
                        icon: CupertinoIcons.flame,
                      ),
                      _TrackingCard(
                        title: 'Achievements',
                        value: '$longestStreak',
                        icon: CupertinoIcons.checkmark_seal_fill,
                      ),
                    ]),
                  );
                },
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
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withAlpha(200), size: 18),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withAlpha(140),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
