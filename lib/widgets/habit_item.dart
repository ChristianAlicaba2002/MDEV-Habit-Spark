import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/models/habit.dart';

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
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: habit.isDone 
                ? [Colors.grey[400]!, Colors.grey[500]!] 
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (habit.isDone ? Colors.grey : colors[0]).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  habit.isDone ? Icons.check_circle : Icons.circle_outlined,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getHabitIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      if (habit.isDone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  // Habit name
                  Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getHabitIcon() {
    // Simple icon mapping based on habit name keywords
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
}
