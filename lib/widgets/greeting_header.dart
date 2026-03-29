import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({super.key, required this.userName});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '☀️';
    } else if (hour < 17) {
      return '🌤️';
    } else {
      return '🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          _getGreetingEmoji(),
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: AppTextStyles.heading2,
            ),
            Text(
              userName,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
