import 'package:flutter/material.dart';
import 'package:habit_spark/models/calendar_event.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';
import 'dart:math';

class EventFormDialog extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarEvent? event;

  const EventFormDialog({
    super.key,
    required this.selectedDate,
    this.event,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  late TextEditingController _trainingNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  String _convertTo24Hour(String time12Hour) {
    final parts = time12Hour.trim().split(' ');
    final timePart = parts[0];
    final period = parts.length > 1 ? parts[1] : 'AM';
    final timeSplit = timePart.split(':');
    var hour = int.parse(timeSplit[0]);
    final minute = timeSplit[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    super.initState();
    _trainingNameController = TextEditingController(
      text: widget.event?.trainingName ?? '',
    );
    
    // Convert 24-hour format to 12-hour format for display
    String startTimeDisplay = '';
    String endTimeDisplay = '';
    
    if (widget.event != null) {
      try {
        final startTime = widget.event!.startTime;
        final endTime = widget.event!.endTime;
        
        if (startTime.isNotEmpty) {
          final startParts = startTime.split(':');
          var startHour = int.parse(startParts[0]);
          final startMinute = startParts[1];
          final startPeriod = startHour >= 12 ? 'PM' : 'AM';
          final startDisplayHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
          startTimeDisplay = '$startDisplayHour:$startMinute $startPeriod';
        }
        
        if (endTime.isNotEmpty) {
          final endParts = endTime.split(':');
          var endHour = int.parse(endParts[0]);
          final endMinute = endParts[1];
          final endPeriod = endHour >= 12 ? 'PM' : 'AM';
          final endDisplayHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
          endTimeDisplay = '$endDisplayHour:$endMinute $endPeriod';
        }
      } catch (e) {
        startTimeDisplay = widget.event?.startTime ?? '';
        endTimeDisplay = widget.event?.endTime ?? '';
      }
    }
    
    _startTimeController = TextEditingController(text: startTimeDisplay);
    _endTimeController = TextEditingController(text: endTimeDisplay);
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
    _notesController = TextEditingController(
      text: widget.event?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final currentTime = controller.text.isNotEmpty 
        ? _parseTime12Hour(controller.text)
        : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => CustomTimePickerDialog(
        initialTime: currentTime,
        onTimeSelected: (time) {
          controller.text = _formatTime12Hour(time);
          Navigator.pop(context);
        },
      ),
    );
  }

  TimeOfDay _parseTime12Hour(String time12Hour) {
    try {
      final parts = time12Hour.trim().split(' ');
      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1] : 'AM';
      final timeSplit = timePart.split(':');
      var hour = int.parse(timeSplit[0]);
      final minute = int.parse(timeSplit[1]);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  bool _validateForm() {
    if (_trainingNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Training name is required')),
      );
      return false;
    }
    if (_startTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Check In time is required')),
      );
      return false;
    }
    if (_endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Check Out time is required')),
      );
      return false;
    }
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Location is required')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event == null ? 'Add Workout' : 'Edit Workout',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: 20),

            // Training Name
            TextField(
              controller: _trainingNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., Leg Day',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.fitness_center, color: Color(0xFFF39C12)),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Check In Time
            GestureDetector(
              onTap: () => _selectTime(_startTimeController),
              child: TextField(
                controller: _startTimeController,
                enabled: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Check In (HH:mm AM/PM)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.login, color: Color(0xFFF39C12)),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Check Out Time
            GestureDetector(
              onTap: () => _selectTime(_endTimeController),
              child: TextField(
                controller: _endTimeController,
                enabled: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Check Out (HH:mm AM/PM)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.logout, color: Color(0xFFF39C12)),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Where did you train?',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFFF39C12)),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'How did it feel?',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.note, color: Color(0xFFF39C12)),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_validateForm()) {
                        setState(() => _isLoading = true);
                        
                        // Convert 12-hour format to 24-hour format for storage
                        final startTime = _convertTo24Hour(_startTimeController.text);
                        final endTime = _convertTo24Hour(_endTimeController.text);
                        
                        final event = CalendarEvent(
                          id: widget.event?.id ?? _generateId(),
                          userId: widget.event?.userId ?? '',
                          trainingName: _trainingNameController.text,
                          date: widget.selectedDate,
                          startTime: startTime,
                          endTime: endTime,
                          location: _locationController.text,
                          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                          createdAt: widget.event?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        Navigator.pop(context, event);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF39C12),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: const Color(0xFFF39C12).withAlpha(128),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const CustomTimePickerDialog({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;
  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedPeriod = 0;

  @override
  void initState() {
    super.initState();
    final hour = widget.initialTime.hour;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 1 : 0;

    _selectedHour = displayHour - 1;
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = period;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriod);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_selectedHour + 1}'.padLeft(2, '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' : ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_selectedMinute}'.padLeft(2, '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _selectedPeriod == 0 ? 'AM' : 'PM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Time Pickers
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  // Hour Picker
                  Expanded(
                    child: ListWheelScrollView(
                      controller: _hourController,
                      itemExtent: 40,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedHour = index);
                      },
                      children: List.generate(
                        12,
                        (index) => Center(
                          child: Text(
                            '${index + 1}'.padLeft(2, '0'),
                            style: TextStyle(
                              color: _selectedHour == index
                                  ? const Color(0xFFF39C12)
                                  : Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Minute Picker
                  Expanded(
                    child: ListWheelScrollView(
                      controller: _minuteController,
                      itemExtent: 40,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedMinute = index);
                      },
                      children: List.generate(
                        60,
                        (index) => Center(
                          child: Text(
                            '${index}'.padLeft(2, '0'),
                            style: TextStyle(
                              color: _selectedMinute == index
                                  ? const Color(0xFFF39C12)
                                  : Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Period Picker
                  Expanded(
                    child: ListWheelScrollView(
                      controller: _periodController,
                      itemExtent: 40,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedPeriod = index);
                      },
                      children: [
                        Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              color: _selectedPeriod == 0
                                  ? const Color(0xFFF39C12)
                                  : Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'PM',
                            style: TextStyle(
                              color: _selectedPeriod == 1
                                  ? const Color(0xFFF39C12)
                                  : Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final hour = _selectedHour + 1;
                      final minute = _selectedMinute;
                      final period = _selectedPeriod;

                      var finalHour = hour;
                      if (period == 1 && hour != 12) {
                        finalHour = hour + 12;
                      } else if (period == 0 && hour == 12) {
                        finalHour = 0;
                      }

                      final time = TimeOfDay(hour: finalHour, minute: minute);
                      widget.onTimeSelected(time);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF39C12),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
