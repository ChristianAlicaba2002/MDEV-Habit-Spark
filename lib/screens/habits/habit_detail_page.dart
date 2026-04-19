import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:habit_spark/services/storage_service.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/screens/habits/create_edit_habit_page.dart';
import 'package:habit_spark/screens/misc/workout_timer_page.dart';
import 'package:habit_spark/screens/misc/history_page.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';
import 'package:habit_spark/utils/error_handler.dart';
import 'package:intl/intl.dart';

class HabitDetailPage extends StatefulWidget {
  final Habit habit;

  const HabitDetailPage({super.key, required this.habit});

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  final HabitLogService _logService = HabitLogService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final HabitService _habitService = HabitService();
  final StreakService _streakService = StreakService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  bool _isCompleting = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final imageFile = File(pickedFile.path);
      final downloadUrl = await _storageService.uploadHabitImage(
        userId: userId,
        habitId: widget.habit.id,
        imageFile: imageFile,
      );

      // Update habit with image URL in Firestore
      await _firestore.collection('habits').doc(widget.habit.id).update({
        'imageUrl': downloadUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image uploaded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _pickAndUploadImage,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final imageFile = File(pickedFile.path);
      final downloadUrl = await _storageService.uploadHabitImage(
        userId: userId,
        habitId: widget.habit.id,
        imageFile: imageFile,
      );

      // Update habit with image URL in Firestore
      await _firestore.collection('habits').doc(widget.habit.id).update({
        'imageUrl': downloadUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image uploaded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _pickFromCamera,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _completeHabit() async {
    try {
      setState(() => _isCompleting = true);

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // Navigate to workout timer page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutTimerPage(
              habit: widget.habit,
              userId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Choose Photo Source',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: 28),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withAlpha(77),
                            AppColors.primary.withAlpha(26),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(102),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(64),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Camera',
                            style: AppTextStyles.heading5,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Take a photo',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF667EEA).withAlpha(77),
                            const Color(0xFF667EEA).withAlpha(26),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF667EEA).withAlpha(102),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withAlpha(64),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.image_rounded,
                              color: Color(0xFF667EEA),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Gallery',
                            style: AppTextStyles.heading5,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose existing',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryPage(habit: widget.habit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () {
              final userId = _authService.currentUser?.uid;
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateEditHabitPage(
                      habit: widget.habit,
                      userId: userId,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (widget.habit.imageUrl != null && widget.habit.imageUrl!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.network(
                          widget.habit.imageUrl!,
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 280,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondary,
                                size: 48,
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(102),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withAlpha(38),
                          AppColors.primary.withAlpha(13),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(77),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: 56,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Add a photo to your habit',
                            style: AppTextStyles.heading5,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capture your progress visually',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            
            // Upload Image Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _showImagePickerOptions,
                icon: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate, size: 22),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload Image',
                  style: AppTextStyles.button,
                ),
                style: AppUIComponents.primaryButtonStyle,
              ),
            ),
            const SizedBox(height: 28),
            
            // Start/Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCompleting ? null : _completeHabit,
                icon: _isCompleting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 28),
                label: Text(
                  _isCompleting ? 'Starting...' : 'Start ${widget.habit.name}',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _logService.getCompletionCount(widget.habit.id),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildStatCard(
                        'Total Completions',
                        '$count',
                        Icons.check_circle_outline,
                        const Color(0xFF4ECDC4),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<double>(
                    future: _logService.getCompletionRate(widget.habit.id),
                    builder: (context, snapshot) {
                      final rate = snapshot.data ?? 0.0;
                      return _buildStatCard(
                        '30-Day Rate',
                        '${rate.toStringAsFixed(0)}%',
                        Icons.trending_up,
                        const Color(0xFFFF6B6B),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(HabitLog log) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    String _formatDuration(int seconds) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;
      
      if (hours > 0) {
        return '${hours}h ${minutes}m ${secs}s';
      }
      return '${minutes}m ${secs}s';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: log.isCompleted
                      ? AppColors.primary.withAlpha(51)
                      : AppColors.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  log.isCompleted ? Icons.check : Icons.close,
                  color: log.isCompleted ? AppColors.primary : AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.isCompleted ? 'Completed' : 'Skipped',
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(log.completedAt),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                timeFormat.format(log.completedAt),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          // Show distance and duration if available
          if (log.distance != null || log.durationSeconds != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (log.distance != null) ...[
                    Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${log.distance!.toStringAsFixed(2)} km',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (log.durationSeconds != null) ...[
                    Icon(
                      Icons.timer,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(log.durationSeconds!),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Show notes if available
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              log.notes!,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No history yet',
              style: AppTextStyles.heading5,
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete this habit to start tracking your progress',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
