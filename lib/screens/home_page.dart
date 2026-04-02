import 'package:flutter/material.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/screens/login_page.dart';
import 'package:habit_spark/screens/notifications_page.dart';
import 'package:habit_spark/screens/habit_detail_page.dart';
import 'package:habit_spark/screens/create_edit_habit_page.dart';
import 'package:habit_spark/screens/daily_checkin_page.dart';
import 'package:habit_spark/screens/calendar_picker_page.dart';
import 'package:habit_spark/screens/training_calendar_page.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/widgets/app_header.dart';
import 'package:habit_spark/widgets/greeting_header.dart';
import 'package:habit_spark/widgets/streak_card.dart';
import 'package:habit_spark/widgets/completed_card.dart';
import 'package:habit_spark/widgets/progress_card.dart';
import 'package:habit_spark/widgets/habit_item.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final HabitService _habitService = HabitService();
  final NotificationService _notificationService = NotificationService();
  final StreakService _streakService = StreakService();
  int _selectedIndex = 0;
  bool _isExpanded = true; // Track expand/collapse state
  int _currentHabitPage = 0; // Track current page in habits breakdown carousel
  late PageController _habitPageController;
  bool _isWeekExpanded = true; // Track week section expand/collapse
  int? _selectedDayIndex; // Track selected day in week view

  @override
  void initState() {
    super.initState();
    _habitPageController = PageController(viewportFraction: 0.85);
    _initializeUserData();
  }

  @override
  void dispose() {
    _habitPageController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserData() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      await _habitService.seedDefaultHabits(userId);
      // Initialize streak data if it doesn't exist
      await _streakService.getUserStreak(userId);
      // Check streak status on login
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

  void _showProfileMenu() async {
    final user = _authService.currentUser;
    final userId = user?.uid;

    // Fetch user data to get photo URL
    UserModel? userData;
    if (userId != null) {
      userData = await _authService.getUserData(userId);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Photo with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondary,
                    backgroundImage:
                        (userData?.photoUrl != null &&
                            userData!.photoUrl.isNotEmpty)
                        ? NetworkImage(userData.photoUrl)
                        : null,
                    child:
                        (userData?.photoUrl == null ||
                            userData!.photoUrl.isEmpty)
                        ? Text(
                            (user?.email?.substring(0, 1).toUpperCase() ?? 'U'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'
                          .trim()
                          .isEmpty
                      ? user?.email?.split('@')[0] ?? 'User'
                      : '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'
                            .trim(),
                  style: AppTextStyles.heading4,
                ),
                const SizedBox(height: 4),

                // Joined date
                Text(
                  'Joined ${_getJoinedDate()}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 24),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit Profile - Coming soon'),
                        ),
                      );
                    },
                    style: AppUIComponents.primaryButtonStyle,
                    child: const Text(
                      'EDIT PROFILE',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // MY STUFF Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MY STUFF',
                    style: AppTextStyles.labelSmall,
                  ),
                ),
                const SizedBox(height: 16),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.apps_outlined,
                  title: 'Connected Apps & Devices',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connected Apps - Coming soon'),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.local_offer_outlined,
                  title: 'Offers',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offers - Coming soon')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings - Coming soon')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    Navigator.pop(context); // Close profile menu
                    await _authService.signOut();
                    // Let main.dart handle navigation via StreamBuilder
                  },
                  isDestructive: true,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _getJoinedDate() {
    final now = DateTime.now();
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';
    final userName = user?.email?.split('@')[0] ?? 'User';
    final userInitial = user?.email?.substring(0, 1).toUpperCase() ?? 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<Habit>>(
          stream: _habitService.getHabitsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      style: AppUIComponents.primaryButtonStyle,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final habits = snapshot.data ?? [];
            final completedCount = habits.where((h) => h.isDone == true).length;
            final totalCount = habits.length;

            return _selectedIndex == 0
                ? _buildDashboard(
                    userName,
                    userInitial,
                    userId,
                    habits,
                    completedCount,
                    totalCount,
                  )
                : _buildStatsPage();
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          iconSize: 20,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.bar_chart_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.bar_chart),
              ),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(
    String userName,
    String userInitial,
    String userId,
    List<Habit> habits,
    int completedCount,
    int totalCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding based on screen width
        final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 16.0;
        final cardSpacing = constraints.maxWidth < 360 ? 12.0 : 16.0;
        final verticalSpacing = constraints.maxWidth < 360 ? 20.0 : 24.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: StreamBuilder<int>(
                  stream: _notificationService.getUnreadCountStream(userId),
                  builder: (context, notificationSnapshot) {
                    final unreadCount = notificationSnapshot.data ?? 0;

                    return StreamBuilder<UserModel?>(
                      stream: _authService.getUserDataStream(userId),
                      builder: (context, userSnapshot) {
                        final photoUrl = userSnapshot.data?.photoUrl;

                        return AppHeader(
                          onNotificationTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                          },
                          onProfileTap: _showProfileMenu,
                          onCalendarTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TrainingCalendarPage(),
                              ),
                            );
                          },
                          notificationCount: unreadCount,
                          userInitial: userInitial,
                          photoUrl: photoUrl,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: verticalSpacing + 8),
                    GreetingHeader(userName: userName),
                    SizedBox(height: verticalSpacing + 16),
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder<Map<String, dynamic>>(
                            stream: _streakService.getStreakStream(userId),
                            builder: (context, streakSnapshot) {
                              final streakDays =
                                  streakSnapshot.data?['currentStreak'] ?? 0;
                              return StreakCard(streakDays: streakDays);
                            },
                          ),
                        ),
                        SizedBox(width: cardSpacing),
                        Expanded(
                          child: CompletedCard(completedCount: completedCount),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),
                    ProgressCard(
                      completedHabits: completedCount,
                      totalHabits: totalCount,
                    ),
                    SizedBox(height: verticalSpacing),
                    // Daily Check-In banner
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyCheckInPage(),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: AppUIComponents.gradientDecoration(
                          startColor: AppColors.primary,
                          endColor: AppColors.primaryDark,
                          borderRadius: 18,
                        ).copyWith(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.checklist_rounded, color: AppColors.textPrimary, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Daily Check-In',
                                    style: AppTextStyles.heading5,
                                  ),
                                  Text(
                                    completedCount == totalCount && totalCount > 0
                                        ? 'All done! Great work today 🎉'
                                        : '$completedCount of $totalCount habits done',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textPrimary.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Habits',
                          style: AppTextStyles.heading4,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    _isExpanded ? 'COLLAPSE' : 'EXPAND',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showAddHabitDialog,
                              child: const Icon(
                                Icons.add,
                                color: AppColors.textPrimary,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    habits.isEmpty
                        ? _buildEmptyState()
                        : AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isExpanded
                                ? _buildHabitList(habits, userId)
                                : const SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        'Tap EXPAND to view habits',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first habit',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits, String userId) {
    final rows = <Widget>[];
    for (int rowIndex = 0; rowIndex < (habits.length / 3).ceil(); rowIndex++) {
      final startIndex = rowIndex * 3;
      final endIndex = (startIndex + 3).clamp(0, habits.length);
      final rowHabits = habits.sublist(startIndex, endIndex);

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                Expanded(
                  child: i < rowHabits.length
                      ? RepaintBoundary(
                          child: HabitItem(
                            habit: rowHabits[i],
                            index: startIndex + i,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HabitDetailPage(habit: rowHabits[i]),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                ),
                if (i < 2) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildStatsPage() {
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          const Text(
            'Progress Analytics',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),

          // Streak Stats
          StreamBuilder<Map<String, dynamic>>(
            stream: _streakService.getStreakStream(userId),
            builder: (context, snapshot) {
              final streakData = snapshot.data ?? {};
              final currentStreak = streakData['currentStreak'] ?? 0;
              final longestStreak = streakData['longestStreak'] ?? 0;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RepaintBoundary(
                          child: _buildAnalyticsCard(
                            'Current Streak',
                            '$currentStreak',
                            'days',
                            Icons.local_fire_department,
                            const Color(0xFFFF6B6B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RepaintBoundary(
                          child: _buildAnalyticsCard(
                            'Longest Streak',
                            '$longestStreak',
                            'days',
                            Icons.emoji_events,
                            const Color(0xFFFFD93D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Habits Overview
          StreamBuilder<List<Habit>>(
            stream: _habitService.getHabitsStream(userId),
            builder: (context, snapshot) {
              final habits = snapshot.data ?? [];
              final totalHabits = habits.length;
              final completedToday = habits.where((h) => h.isDone == true).length;
              final completionRate = totalHabits > 0
                  ? ((completedToday / totalHabits) * 100).toStringAsFixed(0)
                  : '0';

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RepaintBoundary(
                          child: _buildAnalyticsCard(
                            'Total Habits',
                            '$totalHabits',
                            'habits',
                            Icons.list_alt,
                            const Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RepaintBoundary(
                          child: _buildAnalyticsCard(
                            'Today\'s Rate',
                            '$completionRate%',
                            'completed',
                            Icons.trending_up,
                            const Color(0xFF95E1D3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Weekly Progress Section
          _buildWeeklyProgress(userId),
          const SizedBox(height: 32),

          // Habits Breakdown
          _HabitsBreakdownWidget(
            userId: userId,
            buildHabitProgressCard: _buildHabitProgressCard,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.captionSmall,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(String userId) {
    return _WeeklyProgressWidget(userId: userId);
  }

  Widget _buildHabitProgressCard(Habit habit, int index) {
    // Gradient colors for cards
    final gradients = [
      [AppColors.streakStart, AppColors.streakEnd],
      [AppColors.primary, AppColors.primaryDark],
      [AppColors.accent, AppColors.accentDark],
      [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
      [const Color(0xFFFF6B9D), const Color(0xFFC44569)],
      [const Color(0xFF00D2FF), const Color(0xFF3A7BD5)],
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                Expanded(
                  child: Text(
                    habit.name,
                    style: AppTextStyles.heading5.copyWith(color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    habit.isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.isDone ? 'Completed today' : 'Not completed yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to view details',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentHabitPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentHabitPage == index
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyHabitsState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.insights,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No habits yet',
              style: AppTextStyles.heading5,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create habits to see your progress analytics',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressWidget extends StatefulWidget {
  final String userId;

  const _WeeklyProgressWidget({required this.userId});

  @override
  State<_WeeklyProgressWidget> createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<_WeeklyProgressWidget> {
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return Column(
      children: [
        // Header without expand/collapse
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Week',
              style: AppTextStyles.heading4,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Always visible content
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final dayName = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ][day.weekday - 1];
              final isToday = day.day == now.day && day.month == now.month;
              final isSelected = _selectedDayIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : (isToday
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                        fontSize: 12,
                        fontWeight: (isSelected || isToday)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isToday
                                  ? AppColors.primary
                                  : AppColors.surfaceAlt),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isToday
                                    ? AppColors.primary
                                    : AppColors.border),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: (isSelected || isToday)
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _HabitsBreakdownWidget extends StatefulWidget {
  final String userId;
  final Widget Function(Habit, int) buildHabitProgressCard;

  const _HabitsBreakdownWidget({
    required this.userId,
    required this.buildHabitProgressCard,
  });

  @override
  State<_HabitsBreakdownWidget> createState() => _HabitsBreakdownWidgetState();
}

class _HabitsBreakdownWidgetState extends State<_HabitsBreakdownWidget> {
  late PageController _habitPageController;
  int _currentHabitPage = 0;
  final HabitService _habitService = HabitService();

  @override
  void initState() {
    super.initState();
    _habitPageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _habitPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habits Breakdown',
          style: AppTextStyles.heading4,
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Habit>>(
          stream: _habitService.getHabitsStream(widget.userId),
          builder: (context, snapshot) {
            final habits = snapshot.data ?? [];

            if (habits.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No habits yet',
                        style: AppTextStyles.heading5,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create habits to see your progress analytics',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
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
                    controller: _habitPageController,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padEnds: false,
                    onPageChanged: (index) {
                      setState(() {
                        _currentHabitPage = index;
                      });
                    },
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 8,
                          right: index == habits.length - 1 ? 0 : 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HabitDetailPage(habit: habits[index]),
                              ),
                            );
                          },
                          child: widget.buildHabitProgressCard(
                            habits[index],
                            index,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(habits.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentHabitPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentHabitPage == index
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
