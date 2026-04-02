import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:habit_spark/widgets/error_widget.dart';
import 'package:habit_spark/utils/error_handler.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/constants/app_text_styles.dart';
import 'package:habit_spark/constants/app_ui_components.dart';

class HistoryPage extends StatefulWidget {
  final Habit habit;

  const HistoryPage({
    super.key,
    required this.habit,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HabitLogService _logService = HabitLogService();
  final Set<String> _selectedLogs = {};
  bool _isSelectionMode = false;

  Future<void> _selectAllAndDelete(List<HabitLog> logs) async {
    // Select all logs
    setState(() {
      _selectedLogs.clear();
      _selectedLogs.addAll(logs.map((log) => log.id));
    });

    // Show confirmation modal
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Delete All Workouts?',
            style: AppTextStyles.heading4,
          ),
          content: Text(
            'Delete all ${logs.length} workout(s)? This action cannot be undone.',
            style: AppTextStyles.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: AppTextStyles.labelMedium,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete All',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (final logId in _selectedLogs) {
        await _logService.deleteHabitLog(logId);
      }

      if (mounted) {
        setState(() {
          _selectedLogs.clear();
          _isSelectionMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Deleted ${logs.length} workout(s)'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // If cancelled, deselect all
      setState(() {
        _selectedLogs.clear();
      });
    }
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
        title: _isSelectionMode
            ? Text(
                '${_selectedLogs.length} selected',
                style: AppTextStyles.heading4,
              )
            : Text(
                '${widget.habit.name} - History',
                style: AppTextStyles.heading4,
              ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _selectedLogs.isEmpty
                  ? null
                  : () => _deleteSelectedLogs(),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedLogs.clear();
                });
              },
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<HabitLog>>(
        stream: _logService.getHabitLogsStream(widget.habit.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingStateWidget(
              message: 'Loading history...',
            );
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              title: 'Failed to Load History',
              message: ErrorHandler.getErrorMessage(snapshot.error),
              icon: Icons.history,
              onRetry: () => setState(() {}),
            );
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Select All Header
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedLogs.length == logs.length && logs.isNotEmpty) {
                            _selectedLogs.clear();
                          } else {
                            _selectedLogs.clear();
                            _selectedLogs.addAll(logs.map((log) => log.id));
                          }
                        });
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _selectedLogs.isNotEmpty ? Colors.grey : Colors.transparent,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: _selectedLogs.isNotEmpty
                            ? const Icon(
                                Icons.check,
                                color: AppColors.textPrimary,
                                size: 12,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _selectedLogs.isEmpty
                        ? const Text(
                            'Select all',
                            style: AppTextStyles.labelMedium,
                          )
                        : Text(
                            'Select ${_selectedLogs.length} items',
                            style: AppTextStyles.labelMedium,
                          ),
                    const Spacer(),
                    if (_selectedLogs.isNotEmpty)
                      GestureDetector(
                        onTap: () => _deleteSelectedLogs(),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
              // List of items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedLogs.contains(logs[index].id);
                    return _buildLogItem(logs[index], isSelected);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogItem(HabitLog log, bool isSelected) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    String _formatDuration(int seconds) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m ${secs}s';
      }
      return '${minutes}m ${secs}s';
    }

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        _logService.deleteHabitLog(log.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout deleted'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Delete Workout?',
                style: AppTextStyles.heading4,
              ),
              content: const Text(
                'This action cannot be undone.',
                style: AppTextStyles.bodySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: AppTextStyles.labelMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Delete',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_selectedLogs.contains(log.id)) {
              _selectedLogs.remove(log.id);
            } else {
              _selectedLogs.add(log.id);
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey : Colors.transparent,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.textPrimary,
                            size: 12,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.isCompleted ? 'Completed' : 'Skipped',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(log.completedAt),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Show distance and duration if available
              if (log.distance != null || log.durationSeconds != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (log.distance != null) ...[
                        Icon(
                          Icons.location_on,
                          color: const Color(0xFF4ECDC4),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${log.distance!.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (log.durationSeconds != null) ...[
                        Icon(
                          Icons.timer,
                          color: const Color(0xFF4ECDC4),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(log.durationSeconds!),
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSelectedLogs() async {
    final count = _selectedLogs.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Delete Selected Workouts?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Delete $count workout(s)? This action cannot be undone.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (final logId in _selectedLogs) {
        await _logService.deleteHabitLog(logId);
      }

      if (mounted) {
        setState(() {
          _selectedLogs.clear();
          _isSelectionMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Deleted $count workout(s)'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No history yet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete this habit to start tracking your progress',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
