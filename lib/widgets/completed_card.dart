import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';

class CompletedCard extends StatelessWidget {
  final int completedCount;

  const CompletedCard({super.key, required this.completedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.completedStart, AppColors.completedEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.textPrimary, size: 28),
              SizedBox(width: 8),
              Text('Completed', style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text('$completedCount', style: AppTextStyles.display1),
          const Text('habits today', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
