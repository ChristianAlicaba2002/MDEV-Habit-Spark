import 'package:flutter/material.dart';
import 'package:habit_spark/models/calendar_event.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';

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

  @override
  void initState() {
    super.initState();
    _trainingNameController = TextEditingController(
      text: widget.event?.trainingName ?? '',
    );
    _startTimeController = TextEditingController(
      text: widget.event?.startTime ?? '',
    );
    _endTimeController = TextEditingController(
      text: widget.event?.endTime ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
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
        const SnackBar(content: Text('❌ Start time is required')),
      );
      return false;
    }
    if (_endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ End time is required')),
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
              widget.event == null ? 'Add Event' : 'Edit Event',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: 20),

            // Training Name
            TextField(
              controller: _trainingNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppUIComponents.inputDecoration(
                hintText: 'Training Name',
                prefixIcon: Icons.fitness_center,
              ),
            ),
            const SizedBox(height: 16),

            // Start Time
            GestureDetector(
              onTap: () => _selectTime(_startTimeController),
              child: TextField(
                controller: _startTimeController,
                enabled: false,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: AppUIComponents.inputDecoration(
                  hintText: 'Start Time (HH:mm)',
                  prefixIcon: Icons.schedule,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // End Time
            GestureDetector(
              onTap: () => _selectTime(_endTimeController),
              child: TextField(
                controller: _endTimeController,
                enabled: false,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: AppUIComponents.inputDecoration(
                  hintText: 'End Time (HH:mm)',
                  prefixIcon: Icons.schedule,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: _locationController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppUIComponents.inputDecoration(
                hintText: 'Location',
                prefixIcon: Icons.location_on,
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
                      backgroundColor: AppColors.textSecondary,
                      foregroundColor: AppColors.textPrimary,
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
                      if (_validateForm()) {
                        final event = CalendarEvent(
                          id: widget.event?.id ?? '',
                          userId: widget.event?.userId ?? '',
                          trainingName: _trainingNameController.text,
                          date: widget.selectedDate,
                          startTime: _startTimeController.text,
                          endTime: _endTimeController.text,
                          location: _locationController.text,
                          createdAt: widget.event?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        Navigator.pop(context, event);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save', style: AppTextStyles.button),
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
