import 'package:flutter/material.dart';
import 'package:habit_spark/models/notification_model.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  IconData _getIconForType(String type) {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events_outlined;
      case 'streak':
        return Icons.local_fire_department_outlined;
      case 'reminder':
        return Icons.alarm;
      case 'health':
        return Icons.directions_run;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'achievement':
        return const Color(0xFFFFD700); // Gold
      case 'streak':
        return const Color(0xFFFF4500); // OrangeRed
      case 'reminder':
        return AppColors.primary;
      case 'health':
        return const Color(0xFF00FA9A); // SpringGreen
      default:
        return Colors.white70;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            _buildMenuButton(userId),
            const SizedBox(width: 8),
          ],
        ),
        body: StreamBuilder<List<NotificationModel>>(
          stream: _notificationService.getNotificationsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(const Duration(milliseconds: 800));
              },
              color: AppColors.primary,
              backgroundColor: const Color(0xFF1E2E2E),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(notification);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton(String userId) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      color: const Color(0xFF253D3D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white70),
      onSelected: (value) async {
        HapticFeedback.mediumImpact();
        if (value == 'mark_all_read') {
          await _notificationService.markAllAsRead(userId);
        } else if (value == 'delete_all') {
          _showDeleteAllConfirmation(userId);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'mark_all_read',
          child: Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text('Mark all read', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete_all',
          child: Row(
            children: [
              Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text('Clear all', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteAllConfirmation(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF253D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear All', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all notifications? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.deleteAllNotifications(userId);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.bell_slash,
              size: 64,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All quiet for now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something\nimportant happens.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final color = _getColorForType(notification.type);
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        _notificationService.deleteNotification(notification.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            if (!notification.isRead) {
              _notificationService.markAsRead(notification.id);
            }
          },
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Column
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.15), width: 1),
                  ),
                  child: Icon(
                    _getIconForType(notification.type),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
