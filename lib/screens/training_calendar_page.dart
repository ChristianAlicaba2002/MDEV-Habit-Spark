import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/calendar_event.dart';
import 'package:habit_spark/services/calendar_event_service.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/screens/event_form_dialog.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';

class TrainingCalendarPage extends StatefulWidget {
  const TrainingCalendarPage({super.key});

  @override
  State<TrainingCalendarPage> createState() => _TrainingCalendarPageState();
}

class _TrainingCalendarPageState extends State<TrainingCalendarPage> {
  final CalendarEventService _eventService = CalendarEventService();
  final AuthService _authService = AuthService();
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = DateTime.now();
  }

  String _formatTime12Hour(String time24Hour) {
    try {
      final parts = time24Hour.split(':');
      var hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time24Hour;
    }
  }

  Future<void> _addEvent() async {
    final event = await showDialog<CalendarEvent>(
      context: context,
      builder: (context) => EventFormDialog(selectedDate: _selectedDate),
    );

    if (event != null && mounted) {
      try {
        final userId = _authService.currentUser?.uid ?? '';
        final eventWithUser = event.copyWith(userId: userId);
        await _eventService.addEvent(eventWithUser);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Rebuild the calendar to show the new event
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editEvent(CalendarEvent event) async {
    if (event.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error: Event ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedEvent = await showDialog<CalendarEvent>(
      context: context,
      builder: (context) => EventFormDialog(
        selectedDate: event.date,
        event: event,
      ),
    );

    if (updatedEvent != null && mounted) {
      try {
        await _eventService.updateEvent(event.id, updatedEvent);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    if (event.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error: Event ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Workout?', style: AppTextStyles.heading4),
        content: const Text(
          'This action cannot be undone.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: AppTextStyles.labelMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _eventService.deleteEvent(event.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout deleted'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Training Calendar', style: AppTextStyles.heading4),
        actions: [
          GestureDetector(
            onTap: _addEvent,
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.add, color: Color(0xFFF39C12), size: 28),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CalendarEvent>>(
        stream: _eventService.getEventsForMonth(userId, _focusedDate),
        builder: (context, snapshot) {
          final monthEvents = snapshot.data ?? [];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Grid
                _buildCalendarGrid(monthEvents),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(List<CalendarEvent> monthEvents) {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Month/Year Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFFF39C12)),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month - 1,
                    );
                  });
                },
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Text(
                DateFormat('MMM yyyy').format(_focusedDate),
                style: AppTextStyles.heading5.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFFF39C12)),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month + 1,
                    );
                  });
                },
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Day headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              final isCurrentMonth = dayOffset > 0 && dayOffset <= daysInMonth;
              final day = isCurrentMonth ? dayOffset : 0;

              if (!isCurrentMonth) {
                return const SizedBox();
              }

              final date = DateTime(_focusedDate.year, _focusedDate.month, day);
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;
              final isSelected = _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;

              // Check if this date has events
              final hasEvents = monthEvents.any((event) =>
                  event.date.year == date.year &&
                  event.date.month == date.month &&
                  event.date.day == date.day);

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  if (hasEvents) {
                    _showEventsModal(date, monthEvents);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xFFF39C12).withOpacity(0.15)
                        : isToday
                            ? Color(0xFFF39C12).withOpacity(0.08)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFFF39C12).withOpacity(0.6)
                          : isToday
                              ? Color(0xFFF39C12).withOpacity(0.4)
                              : Colors.transparent,
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      // Event dot
                      if (hasEvents)
                        Positioned(
                          bottom: 1,
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF39C12),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.trainingName,
                      style: AppTextStyles.heading5,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.startTime} - ${event.endTime}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () => _editEvent(event),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _deleteEvent(event),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEventsModal(DateTime date, List<CalendarEvent> allEvents) {
    final dayEvents = allEvents
        .where((event) =>
            event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day)
        .toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM dd, yyyy').format(date),
                style: AppTextStyles.heading4,
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayEvents.length,
                itemBuilder: (context, index) {
                  final event = dayEvents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.trainingName,
                                    style: AppTextStyles.heading5,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatTime12Hour(event.startTime)} - ${_formatTime12Hour(event.endTime)}',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (event.notes != null && event.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      event.notes!,
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFFF39C12)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _editEvent(event);
                                  },
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteEvent(event);
                                  },
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
