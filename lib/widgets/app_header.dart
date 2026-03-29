import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final int notificationCount;
  final String userInitial;

  const AppHeader({
    super.key,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.notificationCount,
    required this.userInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Habit Spark',
          style: AppTextStyles.heading3,
        ),
        Row(
          children: [
            // Notifications Icon
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.textPrimary,
                  onPressed: onNotificationTap,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
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
            const SizedBox(width: 8),
            // Profile Icon
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary,
                child: Text(
                  userInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
