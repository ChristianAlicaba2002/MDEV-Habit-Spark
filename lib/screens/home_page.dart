import 'package:flutter/material.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/screens/login_page.dart';
import 'package:habit_spark/models/habit.dart';
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
  int _selectedIndex = 0;

  void _showAddHabitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Habit'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter habit name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final userId = _authService.currentUser?.uid;
                if (userId != null) {
                  await _habitService.addHabit(userId, controller.text);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    final user = _authService.currentUser;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.secondary,
              child: Text(
                (user?.email?.substring(0, 1).toUpperCase() ?? 'U'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Unknown',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Member since ${DateTime.now().year}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile - Coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings - Coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

            final habits = snapshot.data ?? [];
            final completedCount = habits.where((h) => h.isDone).length;
            final totalCount = habits.length;

            return _selectedIndex == 0
                ? _buildDashboard(
                    userName, userInitial, habits, completedCount, totalCount)
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

  Widget _buildDashboard(String userName, String userInitial, List<Habit> habits,
      int completedCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            onProfileTap: _showProfileMenu,
            notificationCount: 3,
            userInitial: userInitial,
          ),
          const SizedBox(height: 32),
          GreetingHeader(userName: userName),
          const SizedBox(height: 40),
          Row(
            children: [
              const Expanded(child: StreakCard(streakDays: 7)),
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
              const Text('Today\'s Habits', style: AppTextStyles.heading4),
              Text(
                '$completedCount/$totalCount',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: habits.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitItem(
                        habit: habit,
                        onTap: () => _habitService.toggleHabit(
                          habit.id,
                          habit.isDone,
                        ),
                      );
                    },
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
              color: AppColors.textSecondary,
            ),
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

  Widget _buildStatsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Statistics',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
