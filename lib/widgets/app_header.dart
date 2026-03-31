import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onCalendarTap;
  final int notificationCount;
  final String userInitial;
  final String? photoUrl;

  const AppHeader({
    super.key,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.onCalendarTap,
    required this.notificationCount,
    required this.userInitial,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          // Center - App Logo/Name (absolutely centered)
          Align(
            alignment: Alignment.center,
            child: const Text(
              'HabitSpark',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Left and Right icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Calendar Icon
              IconButton(
                icon: const Icon(Icons.calendar_month),
                color: Colors.white,
                iconSize: 24,
                onPressed: onCalendarTap ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calendar - Coming soon')),
                  );
                },
              ),
              
              // Right side - Notification and Profile
              Row(
                children: [
                  // Notifications Icon (same size as profile, no background)
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile Icon
                  GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: AppColors.secondary,
                      backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: (photoUrl == null || photoUrl!.isEmpty)
                          ? Text(
                              userInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
