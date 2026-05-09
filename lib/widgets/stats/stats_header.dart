import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/screens/misc/notifications_page.dart';
import 'package:flutter/services.dart';
import 'package:habit_spark/constants/app_colors.dart';

class StatsHeader extends StatelessWidget {
  final String userName;
  final String userInitial;
  final String userId;

  const StatsHeader({
    super.key,
    required this.userName,
    required this.userInitial,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey, $userName",
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<int>(
              stream: NotificationService().getUnreadCountStream(userId),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return _HeaderIcon(
                  icon: CupertinoIcons.bell, 
                  hasNotification: unreadCount > 0,
                  notificationCount: unreadCount,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsPage(),
                      ),
                    );
                  },
                );
              }
            ),
            const SizedBox(width: 12),
            _HeaderIcon(
              child: Text(
                userInitial,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final bool hasNotification;
  final int notificationCount;
  final VoidCallback? onTap;

  const _HeaderIcon({
    this.icon, 
    this.child, 
    this.hasNotification = false,
    this.notificationCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 20),
            if (child != null) child!,
            if (hasNotification)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    notificationCount > 9 ? '!' : notificationCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
