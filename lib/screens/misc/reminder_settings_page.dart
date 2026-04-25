import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/services/reminder_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

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
    _selectedTime = TimeOfDay(hour: 9, minute: 0);
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
              backgroundColor: const Color(0xFF1E293B),
              hourMinuteTextColor: Colors.white,
              dialHandColor: AppColors.primary,
              dialBackgroundColor: const Color(0xFF2C2C2E),
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
            backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_left,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Reminder Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Habit name
                          Text(
                            'Habit',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              widget.habitName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Enable reminder toggle
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3C),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.bell,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text(
                                    'Enable Reminder',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: _isEnabled,
                                  activeColor: AppColors.primary,
                                  onChanged: _toggleReminder,
                                ),
                              ],
                            ),
                          ),

                          if (_isEnabled) ...[
                            const SizedBox(height: 24),

                            // Time picker
                            Text(
                              'Reminder Time',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary.withAlpha(100),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3A3A3C),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.clock,
                                        color: Colors.grey[400],
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        _selectedTime.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      CupertinoIcons.chevron_right,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Info box
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(100),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You\'ll receive a daily reminder at ${_selectedTime.toString()} to complete this habit.',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(200),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
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
    );
  }
}
