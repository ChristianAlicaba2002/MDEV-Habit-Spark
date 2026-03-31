import 'package:flutter/material.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/screens/login_page.dart';
import 'package:habit_spark/screens/notifications_page.dart';
import 'package:habit_spark/screens/habit_detail_page.dart';
import 'package:habit_spark/screens/create_edit_habit_page.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeUserData();
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
        MaterialPageRoute(
          builder: (_) => CreateEditHabitPage(userId: userId),
        ),
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
      backgroundColor: const Color(0xFF1A1A1A),
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
                  color: const Color(0xFF4ECDC4),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.secondary,
                backgroundImage: (userData?.photoUrl != null && userData!.photoUrl.isNotEmpty)
                    ? NetworkImage(userData.photoUrl)
                    : null,
                child: (userData?.photoUrl == null || userData!.photoUrl.isEmpty)
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
              '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'.trim().isEmpty 
                  ? user?.email?.split('@')[0] ?? 'User'
                  : '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'.trim(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // Joined date
            Text(
              'Joined ${_getJoinedDate()}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile - Coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'EDIT PROFILE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // MY STUFF Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MY STUFF',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
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
                  const SnackBar(content: Text('Connected Apps - Coming soon')),
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
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
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
                Navigator.pop(context);
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
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
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? AppColors.error : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
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
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final habits = snapshot.data ?? [];
            final completedCount = habits.where((h) => h.isDone).length;
            final totalCount = habits.length;

            return _selectedIndex == 0
                ? _buildDashboard(
                    userName, userInitial, userId, habits, completedCount, totalCount)
                : _buildStatsPage();
          },
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddHabitDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(String userName, String userInitial, String userId,
      List<Habit> habits, int completedCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<int>(
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
                    notificationCount: unreadCount,
                    userInitial: userInitial,
                    photoUrl: photoUrl,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          GreetingHeader(userName: userName),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: _streakService.getStreakStream(userId),
                  builder: (context, streakSnapshot) {
                    final streakDays = streakSnapshot.data?['currentStreak'] ?? 0;
                    return StreakCard(streakDays: streakDays);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: CompletedCard(completedCount: completedCount)),
            ],
          ),
          const SizedBox(height: 24),
          ProgressCard(
            completedHabits: completedCount,
            totalHabits: totalCount,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Habits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: habits.isEmpty
                ? _buildEmptyState()
                : AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildHabitGrid(habits, userId),
                    secondChild: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Tap EXPAND to view habits',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first habit',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitGrid(List<Habit> habits, String userId) {
    return ListView.builder(
      itemCount: (habits.length / 3).ceil(),
      itemBuilder: (context, rowIndex) {
        final startIndex = rowIndex * 3;
        final endIndex = (startIndex + 3).clamp(0, habits.length);
        final rowHabits = habits.sublist(startIndex, endIndex);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              for (int i = 0; i < rowHabits.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < rowHabits.length - 1 ? 12 : 0,
                    ),
                    child: HabitItem(
                      habit: rowHabits[i],
                      index: startIndex + i,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HabitDetailPage(habit: rowHabits[i]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // Add empty space if row has less than 3 items
              for (int i = rowHabits.length; i < 3; i++)
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
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
                        child: _buildAnalyticsCard(
                          'Current Streak',
                          '$currentStreak',
                          'days',
                          Icons.local_fire_department,
                          const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnalyticsCard(
                          'Longest Streak',
                          '$longestStreak',
                          'days',
                          Icons.emoji_events,
                          const Color(0xFFFFD93D),
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
              final completedToday = habits.where((h) => h.isDone).length;
              final completionRate = totalHabits > 0
                  ? ((completedToday / totalHabits) * 100).toStringAsFixed(0)
                  : '0';

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          'Total Habits',
                          '$totalHabits',
                          'habits',
                          Icons.list_alt,
                          const Color(0xFF4ECDC4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnalyticsCard(
                          'Today\'s Rate',
                          '$completionRate%',
                          'completed',
                          Icons.trending_up,
                          const Color(0xFF95E1D3),
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
          const Text(
            'This Week',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeeklyProgress(userId),
          const SizedBox(height: 32),

          // Habits Breakdown
          const Text(
            'Habits Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Habit>>(
            stream: _habitService.getHabitsStream(userId),
            builder: (context, snapshot) {
              final habits = snapshot.data ?? [];
              
              if (habits.isEmpty) {
                return _buildEmptyHabitsState();
              }

              return Column(
                children: habits.map((habit) {
                  return _buildHabitProgressItem(habit);
                }).toList(),
              );
            },
          ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(String userId) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) {
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
          final isToday = day.day == now.day && day.month == now.month;
          
          return Column(
            children: [
              Text(
                dayName,
                style: TextStyle(
                  color: isToday ? const Color(0xFF4ECDC4) : Colors.white60,
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isToday 
                      ? const Color(0xFF4ECDC4)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isToday 
                        ? const Color(0xFF4ECDC4)
                        : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHabitProgressItem(Habit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: habit.isDone
                  ? const Color(0xFF4ECDC4).withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              habit.isDone ? Icons.check_circle : Icons.circle_outlined,
              color: habit.isDone ? const Color(0xFF4ECDC4) : Colors.white60,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  habit.isDone ? 'Completed today' : 'Not completed yet',
                  style: TextStyle(
                    color: habit.isDone 
                        ? const Color(0xFF4ECDC4)
                        : Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
        ],
      ),
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
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No habits yet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create habits to see your progress analytics',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
