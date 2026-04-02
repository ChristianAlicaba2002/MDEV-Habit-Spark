import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Calendar Icon (far left)
              IconButton(
                icon: const Icon(Icons.calendar_month),
                color: AppColors.textPrimary,
                iconSize: 21,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onCalendarTap ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calendar - Coming soon')),
                  );
                },
              ),
              
              // Right side - Notification and Profile (far right)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notifications Icon
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                            if (notificationCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
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
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Profile Icon
                  GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.secondary,
                      backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: (photoUrl == null || photoUrl!.isEmpty)
                          ? Text(
                              userInitial,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Center - App Logo/Name (absolutely centered)
          Text(
            'HabitSpark',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
