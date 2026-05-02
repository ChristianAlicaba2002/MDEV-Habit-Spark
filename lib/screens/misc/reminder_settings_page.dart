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
              backgroundColor: const Color(0xFF2C3E3E), // Updated to match gradient
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

  Future<void> _saveReminder() async {
    try {
      if (_isEnabled) {
        await _reminderService.scheduleHabitReminder(
          habitId: widget.habitId,
          habitName: widget.habitName,
          userId: widget.userId,
          time: _selectedTime,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder set successfully!'),
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
            content: Text('Error setting reminder: $e'),
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
                    const SizedBox(width: 44), // Spacer to balance header
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Habit name
                            Text(
                              'Habit',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
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

                            const SizedBox(height: 32),

                            // Enable reminder toggle
                            GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                                      CupertinoIcons.bell,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Enable Reminder',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: _isEnabled,
                                    activeColor: const Color(0xFF1ABC9C),
                                    trackColor: Colors.white.withOpacity(0.2),
                                    onChanged: _toggleReminder,
                                  ),
                                ],
                              ),
                            ),

                            if (_isEnabled) ...[
                              const SizedBox(height: 32),

                              // Time picker
                              Text(
                                'Reminder Time',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                      Icon(
                                        CupertinoIcons.chevron_right,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Info box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1ABC9C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF1ABC9C).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.info_circle,
                                      color: Color(0xFF1ABC9C),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'You\'ll receive a daily reminder at ${_selectedTime.format(context)} to complete this habit.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
