import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/models/habit.dart';

class HabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitItem({
    super.key,
    required this.habit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: habit.isDone ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: habit.isDone ? AppColors.success : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: habit.isDone
              ? const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                )
              : null,
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: AppTextStyles.bodyMedium.copyWith(
            color: habit.isDone ? AppColors.textSecondary : AppColors.textPrimary,
            decoration: habit.isDone ? TextDecoration.lineThrough : TextDecoration.none,
            decorationThickness: 2,
          ),
          child: Text(habit.name),
        ),
        trailing: Icon(
          habit.isDone ? Icons.check_circle : Icons.circle_outlined,
          color: habit.isDone ? AppColors.success : Colors.grey[400],
        ),
      ),
    );
  }
}
