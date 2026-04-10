import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/screens/habit_detail_page.dart';

class HabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final int index;

  const HabitItem({
    super.key,
    required this.habit,
    required this.onTap,
    this.index = 0,
  });

  // Different gradient colors for variety
  List<Color> _getGradientColors() {
    final gradients = [
      [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)], // Green to Blue
      [const Color(0xFFFA709A), const Color(0xFFFEE140)], // Pink to Yellow
      [const Color(0xFFFF9A56), const Color(0xFFFF6A88)], // Orange to Red
      [const Color(0xFF667EEA), const Color(0xFF764BA2)], // Blue to Purple
      [const Color(0xFFF093FB), const Color(0xFFF5576C)], // Purple to Pink
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)], // Blue to Cyan
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGradientColors();
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 90,
        child: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: habit.isDone 
                ? [Colors.grey[400]!, Colors.grey[500]!] 
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (habit.isDone ? Colors.grey : colors[0]).withAlpha(77),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative icon
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  habit.isDone ? Icons.check_circle : Icons.circle_outlined,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and status
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          _getHabitIcon(),
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        if (habit.isDone)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Habit name
                  Text(
                    habit.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  IconData _getHabitIcon() {
    // Use saved icon if available
    if (habit.icon != null) {
      return _getIconFromString(habit.icon!);
    }
    
    // Fallback to name-based detection
    final name = habit.name.toLowerCase();
    if (name.contains('run') || name.contains('jog')) return Icons.directions_run;
    if (name.contains('read')) return Icons.menu_book;
    if (name.contains('water') || name.contains('drink')) return Icons.water_drop;
    if (name.contains('exercise') || name.contains('workout')) return Icons.fitness_center;
    if (name.contains('meditate') || name.contains('yoga')) return Icons.self_improvement;
    if (name.contains('sleep')) return Icons.bedtime;
    if (name.contains('eat') || name.contains('meal')) return Icons.restaurant;
    if (name.contains('study') || name.contains('learn')) return Icons.school;
    if (name.contains('walk')) return Icons.directions_walk;
    if (name.contains('code') || name.contains('program')) return Icons.code;
    return Icons.check_circle_outline;
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'directions_run': return Icons.directions_run;
      case 'fitness_center': return Icons.fitness_center;
      case 'self_improvement': return Icons.self_improvement;
      case 'menu_book': return Icons.menu_book;
      case 'water_drop': return Icons.water_drop;
      case 'restaurant': return Icons.restaurant;
      case 'bedtime': return Icons.bedtime;
      case 'school': return Icons.school;
      case 'code': return Icons.code;
      case 'music_note': return Icons.music_note;
      case 'brush': return Icons.brush;
      case 'camera_alt': return Icons.camera_alt;
      case 'favorite': return Icons.favorite;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'nightlight': return Icons.nightlight;
      case 'local_cafe': return Icons.local_cafe;
      default: return Icons.check_circle_outline;
    }
  }
}
