import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:intl/intl.dart';

class CalendarPickerPage extends StatefulWidget {
  final DateTime? initialDate;

  const CalendarPickerPage({
    super.key,
    this.initialDate,
  });

  @override
  State<CalendarPickerPage> createState() => _CalendarPickerPageState();
}

class _CalendarPickerPageState extends State<CalendarPickerPage> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _focusedDate = _selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Date',
          style: AppTextStyles.heading4,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Grid
            _buildCalendarGrid(),
            const SizedBox(height: 32),

            // Selected Date Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Date',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedDate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Selection',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
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

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
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
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
