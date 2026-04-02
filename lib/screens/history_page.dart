import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/habit_log.dart';
import 'package:habit_spark/services/habit_log_service.dart';
import 'package:habit_spark/widgets/error_widget.dart';
import 'package:habit_spark/utils/error_handler.dart';
import 'package:habit_spark/constants/app_colors.dart';

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
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Delete All Workouts?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Delete all ${logs.length} workout(s)? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete All',
                style: TextStyle(color: Colors.red),
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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSelectionMode
            ? Text(
                '${_selectedLogs.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                '${widget.habit.name} - History',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
              icon: const Icon(Icons.close, color: Colors.white),
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
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
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _selectedLogs.isNotEmpty ? Colors.grey : Colors.transparent,
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: _selectedLogs.isNotEmpty
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _selectedLogs.isEmpty
                        ? const Text(
                            'Select all',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            '${_selectedLogs.length} selected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    const Spacer(),
                    if (_selectedLogs.isNotEmpty)
                      GestureDetector(
                        onTap: () => _deleteSelectedLogs(),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
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
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text(
                'Delete Workout?',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4ECDC4).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4ECDC4).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey : Colors.transparent,
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.isCompleted ? 'Completed' : 'Skipped',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(log.completedAt),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dateFormat.format(log.completedAt),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
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
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Delete $count workout(s)? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
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
