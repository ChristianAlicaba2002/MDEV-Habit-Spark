import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/habit_service.dart';

class CheckInTab extends StatelessWidget {
  final List<Habit> habits;
  final String userId;
  final String userName;
  final String userInitial;
  final HabitService habitService;

  CheckInTab({
    super.key,
    required this.habits,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habitService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF162626),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Habits/Tasks',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: habits.isEmpty
                  ? Center(
                      child: Text(
                        'No habits yet. Start by adding one!',
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return _SimpleHabitCard(
                          habit: habit,
                          userId: userId,
                          habitService: habitService,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _SimpleHabitCard extends StatelessWidget {
  final Habit habit;
  final String userId;
  final HabitService habitService;

  const _SimpleHabitCard({required this.habit, required this.userId, required this.habitService});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => habitService.toggleHabit(habit.id, habit.isDone, userId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: habit.isDone ? Colors.orangeAccent : Colors.white24,
                  width: 2,
                ),
                color: habit.isDone ? Colors.orangeAccent : Colors.transparent,
              ),
              child: habit.isDone ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.outfit(
                    color: habit.isDone ? Colors.white38 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration: habit.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (habit.routine.isNotEmpty)
                  Text(
                    habit.routine,
                    style: GoogleFonts.outfit(
                      color: Colors.orangeAccent.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
