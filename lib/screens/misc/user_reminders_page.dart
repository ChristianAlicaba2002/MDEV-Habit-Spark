import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/reminder_service.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';
import 'package:habit_spark/screens/misc/reminder_settings_page.dart';

class UserRemindersPage extends StatefulWidget {
  final String userId;

  const UserRemindersPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserRemindersPage> createState() => _UserRemindersPageState();
}

class _UserRemindersPageState extends State<UserRemindersPage> {
  final ReminderService _reminderService = ReminderService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final formattedMinute = minute.toString().padLeft(2, '0');
      return '$formattedHour:$formattedMinute $period';
    } catch (e) {
      return timeString;
    }
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'No days selected';
    if (days.length == 7) return 'Everyday';
    if (days.length == 2 && days.contains(6) && days.contains(7)) return 'Weekends';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) return 'Weekdays';

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(days)..sort();
    return sortedDays.map((d) => dayNames[d - 1]).join(', ');
  }

  Stream<List<Habit>> _getHabitsStream() {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .map((snap) {
      final habits = snap.docs
          .map((doc) => Habit.fromMap(doc.data(), doc.id))
          .toList();
      habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return habits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E3E),
              Color(0xFF4A6666),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RoundIconButton(
                      icon: CupertinoIcons.arrow_left,
                      onTap: () => Navigator.pop(context),
                      outlined: true,
                    ),
                    const Text(
                      'Your Reminders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Text(
                  'Tap a habit to configure its reminder',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Content — habits + their reminder status
              Expanded(
                child: StreamBuilder<List<Habit>>(
                  stream: _getHabitsStream(),
                  builder: (context, habitsSnap) {
                    if (habitsSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final habits = habitsSnap.data ?? [];

                    if (habits.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.bell_slash,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a habit first, then set a reminder.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _reminderService.getUserReminders(widget.userId),
                      builder: (context, remindersSnap) {
                        // Build a map of habitId -> reminder data
                        final reminderMap = <String, Map<String, dynamic>>{};
                        for (final r in remindersSnap.data ?? []) {
                          final id = r['habitId'] as String?;
                          if (id != null) reminderMap[id] = r;
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            final reminder = reminderMap[habit.id];
                            final bool hasReminder = reminder != null;
                            final bool isEnabled =
                                hasReminder && (reminder['enabled'] == true);

                            String subtitleText;
                            if (!hasReminder) {
                              subtitleText = 'No reminder set';
                            } else if (!isEnabled) {
                              subtitleText = 'Reminder disabled';
                            } else {
                              final days = List<int>.from(
                                  reminder['selectedDays'] ?? [1, 2, 3, 4, 5, 6, 7]);
                              subtitleText =
                                  '${_formatTime(reminder['time'] ?? '09:00')} • ${_formatDays(days)}';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReminderSettingsPage(
                                        userId: widget.userId,
                                        habitId: habit.id,
                                        habitName: habit.name,
                                      ),
                                    ),
                                  );
                                  setState(() {}); // refresh after returning
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(24),
                                        border: Border.all(
                                          color: isEnabled
                                              ? const Color(0xFF1ABC9C)
                                                  .withOpacity(0.4)
                                              : Colors.white.withOpacity(0.1),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Bell icon
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: isEnabled
                                                  ? const Color(0xFF1ABC9C)
                                                      .withOpacity(0.2)
                                                  : Colors.white
                                                      .withOpacity(0.07),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isEnabled
                                                  ? CupertinoIcons.bell_fill
                                                  : CupertinoIcons.bell_slash,
                                              color: isEnabled
                                                  ? const Color(0xFF1ABC9C)
                                                  : Colors.white
                                                      .withOpacity(0.4),
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  habit.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  subtitleText,
                                                  style: TextStyle(
                                                    color: isEnabled
                                                        ? Colors.white
                                                            .withOpacity(0.7)
                                                        : Colors.white
                                                            .withOpacity(0.4),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Status badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isEnabled
                                                  ? const Color(0xFF1ABC9C)
                                                      .withOpacity(0.15)
                                                  : Colors.white
                                                      .withOpacity(0.07),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isEnabled ? 'ON' : 'OFF',
                                              style: TextStyle(
                                                color: isEnabled
                                                    ? const Color(0xFF1ABC9C)
                                                    : Colors.white
                                                        .withOpacity(0.4),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            CupertinoIcons.chevron_right,
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
