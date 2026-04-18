import 'package:flutter/material.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/utils/migration_helper.dart';

class MigrationPage extends StatefulWidget {
  const MigrationPage({super.key});

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  final AuthService _authService = AuthService();
  bool _isRunning = false;
  String _status = '';

  Future<void> _runMigration() async {
    setState(() {
      _isRunning = true;
      _status = 'Starting migration...';
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        setState(() => _status = '❌ User not authenticated');
        return;
      }

      await MigrationHelper.migrateHabitLogs(userId);
      setState(() => _status = '✅ Migration completed successfully!');
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _runDistribution() async {
    setState(() {
      _isRunning = true;
      _status = 'Starting distribution...';
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        setState(() => _status = '❌ User not authenticated');
        return;
      }

      await MigrationHelper.distributeLogsAcrossHabits(userId);
      setState(() => _status = '✅ Distribution completed successfully!');
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
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
        title: const Text(
          'Data Migration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Habit Logs Migration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This tool helps fix habit logs that may have incorrect or missing habitId values.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Option 1: Assign all to first habit
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha(26),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Option 1: Assign to First Habit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Assigns all logs to your first habit. Use this if you only have one habit.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? null : _runMigration,
                      icon: _isRunning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_isRunning ? 'Running...' : 'Run Migration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Option 2: Distribute across habits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha(26),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Option 2: Distribute Across Habits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Spreads logs evenly across all your habits. Use this if you have multiple habits.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? null : _runDistribution,
                      icon: _isRunning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.shuffle),
                      label: Text(_isRunning ? 'Running...' : 'Distribute Logs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Status
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _status.contains('✅')
                      ? Colors.green.withAlpha(26)
                      : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _status.contains('✅')
                        ? Colors.green.withAlpha(77)
                        : Colors.red.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _status.contains('✅') ? Colors.green : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
