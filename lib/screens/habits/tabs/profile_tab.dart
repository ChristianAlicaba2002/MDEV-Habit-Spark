import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/screens/misc/personal_information_page.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';
import 'package:habit_spark/screens/misc/user_reminders_page.dart';
import 'package:habit_spark/screens/misc/notifications_page.dart';
import 'package:habit_spark/widgets/skeleton_loaders.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/screens/misc/body_stats_page.dart';

class ProfileTab extends StatefulWidget {
  final String userId;
  final AuthService authService;
  final StreakService streakService;
  final List<Habit> habits;
  final VoidCallback onBackTap;

  const ProfileTab({
    super.key,
    required this.userId,
    required this.authService,
    required this.streakService,
    required this.habits,
    required this.onBackTap,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await widget.authService.signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: widget.authService.getUserDataStream(widget.userId),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final user = widget.authService.currentUser;
        final displayName = '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'.trim();
        final name = displayName.isEmpty ? user?.email?.split('@')[0] ?? 'User' : displayName;
        final username = '@${userData?.email.split('@')[0] ?? 'user123'}';

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D1B1B),
                Color(0xFF162A2A),
                Color(0xFF1A3333),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                backgroundColor: const Color(0xFF1E2E2E),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: _isRefreshing
                    ? [const SliverProfileSkeleton()]
                    : [
                    // ── Modern Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RoundIconButton(
                              icon: CupertinoIcons.arrow_left,
                              onTap: widget.onBackTap,
                              outlined: true,
                              isSquare: true,
                            ),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            RoundIconButton(
                              icon: CupertinoIcons.bell,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              ),
                              outlined: true,
                              isSquare: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Premium Profile Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 32,
                          blur: 25,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundColor: Colors.white.withOpacity(0.05),
                                          backgroundImage: (userData?.photoUrl != null && userData!.photoUrl.isNotEmpty)
                                              ? NetworkImage(userData!.photoUrl)
                                              : null,
                                          child: (userData?.photoUrl == null || userData!.photoUrl.isEmpty)
                                              ? Text(
                                                  (user?.email?.substring(0, 1).toUpperCase()) ?? 'U',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 36,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFF1A3333), width: 2),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.camera_fill,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          username,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _ProfileCompletionBar(progress: 0.8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  _StatPill(
                                    label: 'Age',
                                    value: userData?.age != null ? '${userData!.age}' : '21',
                                    unit: 'y.o',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatPill(
                                    label: 'Height',
                                    value: userData?.height != null ? '${userData!.height!.toInt()}' : '165',
                                    unit: 'cm',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatPill(
                                    label: 'Weight',
                                    value: userData?.weight != null ? '${userData!.weight!.toInt()}' : '63',
                                    unit: 'kg',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Settings Sections
                    const _SectionHeader(title: 'Account Settings'),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _GlassSettingTile(
                            icon: CupertinoIcons.person,
                            title: 'Personal Information',
                            subtitle: 'Update your personal details',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PersonalInformationPage(
                                  userId: widget.userId,
                                  authService: widget.authService,
                                  initialData: userData,
                                ),
                              ),
                            ),
                          ),
                          _GlassSettingTile(
                            icon: CupertinoIcons.briefcase,
                            title: 'Body Stats',
                            subtitle: 'Manage your body statistics',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BodyStatsPage(
                                  userId: widget.userId,
                                  authService: widget.authService,
                                  initialData: userData,
                                ),
                              ),
                            ),
                          ),
                          _GlassSettingTile(
                            icon: CupertinoIcons.calendar_badge_minus,
                            title: 'Reminder',
                            subtitle: 'Set your reminders',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserRemindersPage(
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                          _GlassSettingTile(
                            icon: CupertinoIcons.speaker_2,
                            title: 'Sound',
                            subtitle: 'App sound',
                            hasToggle: true,
                          ),
                        ]),
                      ),
                    ),

                    // ── Logout Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                        child: GestureDetector(
                          onTap: () => _showLogoutConfirmation(context),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(CupertinoIcons.arrow_right_to_line, color: Colors.red, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Sign out from your account',
                                        style: TextStyle(
                                          color: Colors.red.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(CupertinoIcons.chevron_right, color: Colors.red.withOpacity(0.4), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCompletionBar extends StatelessWidget {
  final double progress;
  const _ProfileCompletionBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatPill({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool hasToggle;

  const _GlassSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.hasToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        opacity: 0.08,
        blur: 0,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          trailing: hasToggle
              ? CupertinoSwitch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: AppColors.primary,
                )
              : Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
        ),
      ),
    );
  }
}
