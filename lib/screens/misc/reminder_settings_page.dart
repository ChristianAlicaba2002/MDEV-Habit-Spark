import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/services/reminder_service.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';

class ReminderSettingsPage extends StatefulWidget {
  final String userId;
  final String habitId;
  final String habitName;

  const ReminderSettingsPage({
    super.key,
    required this.userId,
    required this.habitId,
    required this.habitName,
  });

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  final _reminderService = ReminderService();
  late TimeOfDay _selectedTime;
  bool _isEnabled = false;
  bool _isLoading = true;

  // Advanced Features State
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // 1 = Mon, 7 = Sun
  bool _skipIfCompleted = false;
  bool _enableSnooze = true;
  bool _motivationalMessages = true;
  bool _progressAwareNudges = true;
  bool _respectQuietHours = false;
  String _customSound = 'Default';

  @override
  void initState() {
    super.initState();
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    try {
      final reminder = await _reminderService.getReminder(
        widget.userId,
        widget.habitId,
      );

      if (reminder != null) {
        final timeParts = (reminder['time'] as String).split(':');
        setState(() {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          _isEnabled = reminder['enabled'] ?? true;
          
          _selectedDays = List<int>.from(reminder['selectedDays'] ?? [1, 2, 3, 4, 5, 6, 7]);
          _skipIfCompleted = reminder['skipIfCompleted'] ?? false;
          _enableSnooze = reminder['enableSnooze'] ?? true;
          _motivationalMessages = reminder['motivationalMessages'] ?? true;
          _progressAwareNudges = reminder['progressAwareNudges'] ?? true;
          _respectQuietHours = reminder['respectQuietHours'] ?? false;
          _customSound = reminder['customSound'] ?? 'Default';
        });
      }
    } catch (e) {
      print('Error loading reminder: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF2C3E3E),
              hourMinuteTextColor: Colors.white,
              dialHandColor: const Color(0xFF1ABC9C),
              dialBackgroundColor: Colors.white.withOpacity(0.1),
              entryModeIconColor: Colors.white,
              helpTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      await _saveReminder();
    }
  }

  Future<void> _selectSound() async {
    final sounds = ['Default', 'Chime', 'Bell', 'Soft Beep', 'Vibrate Only'];
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Notification Sound'),
        actions: sounds.map((sound) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _customSound = sound);
              _saveReminder();
              Navigator.pop(context);
            },
            child: Text(
              sound,
              style: TextStyle(
                color: _customSound == sound ? const Color(0xFF1ABC9C) : Colors.black87,
                fontWeight: _customSound == sound ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _saveReminder() async {
    try {
      if (_isEnabled) {
        await _reminderService.scheduleHabitReminder(
          habitId: widget.habitId,
          habitName: widget.habitName,
          userId: widget.userId,
          time: _selectedTime,
          selectedDays: _selectedDays,
          skipIfCompleted: _skipIfCompleted,
          enableSnooze: _enableSnooze,
          motivationalMessages: _motivationalMessages,
          progressAwareNudges: _progressAwareNudges,
          respectQuietHours: _respectQuietHours,
          customSound: _customSound,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Color(0xFF2ECC71),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving reminder: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _isEnabled = value);

    try {
      if (value) {
        await _reminderService.scheduleHabitReminder(
          habitId: widget.habitId,
          habitName: widget.habitName,
          userId: widget.userId,
          time: _selectedTime,
          selectedDays: _selectedDays,
          skipIfCompleted: _skipIfCompleted,
          enableSnooze: _enableSnooze,
          motivationalMessages: _motivationalMessages,
          progressAwareNudges: _progressAwareNudges,
          respectQuietHours: _respectQuietHours,
          customSound: _customSound,
        );
      } else {
        await _reminderService.cancelHabitReminder(
          habitId: widget.habitId,
          userId: widget.userId,
        );
      }
    } catch (e) {
      setState(() => _isEnabled = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 16,
      opacity: 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final dayIndex = index + 1; // 1-7 (Mon-Sun)
          final isSelected = _selectedDays.contains(dayIndex);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected && _selectedDays.length > 1) {
                  _selectedDays.remove(dayIndex);
                } else if (!isSelected) {
                  _selectedDays.add(dayIndex);
                  _selectedDays.sort();
                }
              });
              _saveReminder();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF1ABC9C) : Colors.white.withOpacity(0.05),
                border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF1ABC9C).withOpacity(0.4), blurRadius: 8)]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 16,
      opacity: 0.1,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF1ABC9C),
            trackColor: Colors.white.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
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
                      'Reminder Settings',
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

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('HABIT'),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              borderRadius: 16,
                              opacity: 0.1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.habitName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildToggleRow(
                              'Enable Notifications',
                              'Receive alerts for this habit',
                              CupertinoIcons.bell,
                              _isEnabled,
                              _toggleReminder,
                            ),

                            if (_isEnabled) ...[
                              const SizedBox(height: 32),
                              
                              // Scheduling Section
                              _buildSectionHeader('CUSTOM SCHEDULING'),
                              GestureDetector(
                                onTap: _selectTime,
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  borderRadius: 16,
                                  opacity: 0.1,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1ABC9C).withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.clock,
                                          color: Color(0xFF1ABC9C),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _selectedTime.format(context),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.5), size: 18),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDaySelector(),

                              const SizedBox(height: 32),

                              // Smart / Contextual Reminders
                              _buildSectionHeader('SMART REMINDERS'),
                              _buildToggleRow(
                                'Skip if completed',
                                'Don\'t remind if already done',
                                CupertinoIcons.check_mark_circled,
                                _skipIfCompleted,
                                (val) {
                                  setState(() => _skipIfCompleted = val);
                                  _saveReminder();
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildToggleRow(
                                'Respect Quiet Hours',
                                'Pause during sleep/focus mode',
                                CupertinoIcons.moon_stars,
                                _respectQuietHours,
                                (val) {
                                  setState(() => _respectQuietHours = val);
                                  _saveReminder();
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildToggleRow(
                                'Snooze & Reschedule',
                                'Allow snoozing for later today',
                                CupertinoIcons.zzz,
                                _enableSnooze,
                                (val) {
                                  setState(() => _enableSnooze = val);
                                  _saveReminder();
                                },
                              ),

                              const SizedBox(height: 32),

                              // Motivation
                              _buildSectionHeader('MOTIVATION & PROGRESS'),
                              _buildToggleRow(
                                'Motivational Messages',
                                'e.g., "Quick 5 min = big win!"',
                                CupertinoIcons.flame,
                                _motivationalMessages,
                                (val) {
                                  setState(() => _motivationalMessages = val);
                                  _saveReminder();
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildToggleRow(
                                'Progress-aware Nudges',
                                'e.g., "Don\'t break your streak!"',
                                CupertinoIcons.graph_square,
                                _progressAwareNudges,
                                (val) {
                                  setState(() => _progressAwareNudges = val);
                                  _saveReminder();
                                },
                              ),

                              const SizedBox(height: 32),
                              
                              // Customization
                              _buildSectionHeader('CUSTOMIZATION'),
                              GestureDetector(
                                onTap: _selectSound,
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  borderRadius: 16,
                                  opacity: 0.1,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.speaker_2,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Notification Sound',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _customSound,
                                              style: TextStyle(
                                                color: const Color(0xFF1ABC9C),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.5), size: 18),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
