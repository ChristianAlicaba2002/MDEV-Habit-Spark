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

class ProfileTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: authService.getUserDataStream(userId),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final user = authService.currentUser;
        final displayName = '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'.trim();
        final name = displayName.isEmpty ? user?.email?.split('@')[0] ?? 'User' : displayName;

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
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Custom Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RoundIconButton(
                            icon: CupertinoIcons.arrow_left,
                            onTap: onBackTap,
                            outlined: true,
                          ),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                          RoundIconButton(
                            icon: CupertinoIcons.bell,
                            onTap: () {},
                            outlined: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Profile Glass Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 30,
                        blur: 20,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  backgroundImage: (userData?.photoUrl != null && userData!.photoUrl.isNotEmpty)
                                      ? NetworkImage(userData!.photoUrl)
                                      : null,
                                  child: (userData?.photoUrl == null || userData!.photoUrl.isEmpty)
                                      ? Text(
                                          (user?.email?.substring(0, 1).toUpperCase()) ?? 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userData?.email.isNotEmpty == true ? userData!.email.split('@')[0] : 'London, United Kingdom',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _StatPill(
                                  label: 'Age',
                                  value: userData?.age != null ? '${userData!.age}' : '27',
                                  unit: 'y.o',
                                ),
                                const SizedBox(width: 12),
                                _StatPill(
                                  label: 'Height',
                                  value: userData?.height != null ? '${userData!.height!.toInt()}' : '170',
                                  unit: 'cm',
                                ),
                                const SizedBox(width: 12),
                                _StatPill(
                                  label: 'Weight',
                                  value: userData?.weight != null ? '${userData!.weight!.toInt()}' : '52',
                                  unit: 'kg',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Account Settings
                  const _SectionHeader(title: 'Account settings'),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _GlassPillItem(
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
                        const SizedBox(height: 12),
                        _GlassPillItem(
                          icon: CupertinoIcons.list_bullet_indent,
                          label: 'Reminder',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserRemindersPage(
                                  userId: userId,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _GlassPillItem(
                          icon: CupertinoIcons.speaker_2,
                          label: 'Sound',
                          hasToggle: true,
                          onTap: () {},
                        ),
                      ]),
                    ),
                  ),

                  // ── Preferences
                  const _SectionHeader(title: 'Preferences'),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _GlassPillItem(
                          icon: CupertinoIcons.person_2,
                          label: 'Experience level',
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),
                        _GlassPillItem(
                          icon: CupertinoIcons.exclamationmark_triangle,
                          label: 'Caution areas',
                          onTap: () {},
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
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

class _GlassPillItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasToggle;
  final VoidCallback onTap;

  const _GlassPillItem({
    required this.icon,
    required this.label,
    this.hasToggle = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (hasToggle)
                  Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF1D3D3D),
                  )
                else
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: Colors.white.withOpacity(0.4),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
