import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';

class ProgressCard extends StatelessWidget {
  final int completedHabits;
  final int totalHabits;

  const ProgressCard({
    super.key,
    required this.completedHabits,
    required this.totalHabits,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalHabits > 0
        ? (completedHabits / totalHabits * 100).toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Progress', style: AppTextStyles.bodyMedium),
              Text('$percentage%', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalHabits > 0 ? completedHabits / totalHabits : 0,
              minHeight: 12,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80
                    ? AppColors.success
                    : percentage >= 50
                    ? AppColors.warning
                    : AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedHabits of $totalHabits habits completed',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
