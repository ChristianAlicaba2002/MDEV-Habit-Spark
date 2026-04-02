import 'package:flutter/material.dart';
import 'dart:async';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';

class WorkoutTimerPage extends StatefulWidget {
  final Habit habit;
  final String userId;

  const WorkoutTimerPage({
    super.key,
    required this.habit,
    required this.userId,
  });

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}

class _WorkoutTimerPageState extends State<WorkoutTimerPage> {
  final HabitLogService _logService = HabitLogService();
  late Timer _timer;
  int _seconds = 0;
  bool _isRunning = false;
  double _distance = 0.0;
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _timer.cancel();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer.cancel();
    setState(() => _isRunning = false);
  }

  bool _isDistanceFilled() {
    final distance = double.tryParse(_distanceController.text) ?? 0.0;
    return distance > 0;
  }

  Future<void> _saveWorkout() async {
    try {
      if (_seconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Please run for at least a few seconds'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _pauseTimer();

      final distance = double.tryParse(_distanceController.text) ?? 0.0;

      await _logService.addHabitLog(
        habitId: widget.habit.id,
        userId: widget.userId,
        isCompleted: true,
        distance: distance > 0 ? distance : null,
        durationSeconds: _seconds,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
        title: Text(
          widget.habit.name,
          style: AppTextStyles.heading4,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timer Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: AppTextStyles.display1.copyWith(
                      color: AppColors.textPrimary,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRunning ? '🏃 Running...' : '⏸️ Paused',
                    style: TextStyle(
                      color: _isRunning ? AppColors.success : AppColors.warning,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Timer Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: AppColors.textPrimary,
                    ),
                    label: Text(
                      _isRunning ? 'Pause' : 'Start',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? AppColors.warning : AppColors.success,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveWorkout,
                    icon: const Icon(
                      Icons.check_circle,
                      color: AppColors.textPrimary,
                    ),
                    label: const Text(
                      'Done',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Distance Input
            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppUIComponents.inputDecoration(
                hintText: 'Distance (km)',
                prefixIcon: Icons.location_on,
              ),
            ),
            const SizedBox(height: 16),

            // Notes Input
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: AppUIComponents.inputDecoration(
                hintText: 'Add notes (optional)',
                prefixIcon: Icons.note,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
