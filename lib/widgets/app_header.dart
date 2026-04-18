import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final int notificationCount;
  final String userInitial;
  final String? photoUrl;
  final String userName;
  final double progress;

  const AppHeader({
    super.key,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.notificationCount,
    required this.userInitial,
    this.photoUrl,
    required this.userName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ── Left: Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(20),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surface,
                backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : null,
                child: (photoUrl == null || photoUrl!.isEmpty)
                    ? Text(
                        userInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Middle: Greeting & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.bolt_fill,
                      color: Colors.white.withAlpha(160),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Progress: ${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withAlpha(160),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Right: Notifications
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bell,
                    color: Colors.white,
                    size: 20,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
