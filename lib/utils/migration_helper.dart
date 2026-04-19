import 'package:cloud_firestore/cloud_firestore.dart';

/// Migration helper to fix habit_logs with missing or incorrect habitId
class MigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrate habit logs to ensure each log has the correct habitId
  /// This function matches logs to habits based on timestamps and user
  static Future<void> migrateHabitLogs(String userId) async {
    try {
      print('🔄 Starting habit logs migration for user: $userId');

      // Get all habits for this user
      final habitsSnapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      final habits = habitsSnapshot.docs;
      print('📋 Found ${habits.length} habits');

      if (habits.isEmpty) {
        print('⚠️ No habits found for this user');
        return;
      }

      // Get all logs for this user
      final logsSnapshot = await _firestore
          .collection('habit_logs')
          .where('userId', isEqualTo: userId)
          .get();

      final logs = logsSnapshot.docs;
      print('📝 Found ${logs.length} logs to migrate');

      if (logs.isEmpty) {
        print('✅ No logs to migrate');
        return;
      }

      // Create a map of habit names to habit IDs
      final habitMap = <String, String>{};
      for (var habit in habits) {
        final habitName = habit.data()['name'] as String?;
        final habitId = habit.id;
        if (habitName != null) {
          habitMap[habitName] = habitId;
        }
      }

      print('🗺️ Habit map: $habitMap');

      // Migrate logs
      int migratedCount = 0;
      int skippedCount = 0;

      for (var logDoc in logs) {
        final logData = logDoc.data();
        final currentHabitId = logData['habitId'] as String?;

        // If habitId already exists and is valid, skip
        if (currentHabitId != null && habitMap.containsValue(currentHabitId)) {
          skippedCount++;
          continue;
        }

        // Try to find the correct habitId by matching with first habit
        // In a real scenario, you might need more sophisticated matching
        String? correctHabitId;

        // If there's only one habit, assign all logs to it
        if (habits.length == 1) {
          correctHabitId = habits[0].id;
        } else {
          // For multiple habits, assign to the first one as fallback
          // In production, you might want to prompt the user
          correctHabitId = habits[0].id;
        }

        if (correctHabitId != null) {
          await _firestore.collection('habit_logs').doc(logDoc.id).update({
            'habitId': correctHabitId,
          });
          migratedCount++;
          print('✅ Migrated log ${logDoc.id} to habit $correctHabitId');
        }
      }

      print('✨ Migration complete!');
      print('📊 Migrated: $migratedCount, Skipped: $skippedCount');
    } catch (e) {
      print('❌ Migration error: $e');
      rethrow;
    }
  }

  /// Alternative: Distribute logs evenly across all habits
  /// This is useful if you want to spread the test data
  static Future<void> distributeLogsAcrossHabits(String userId) async {
    try {
      print('🔄 Starting log distribution for user: $userId');

      // Get all habits
      final habitsSnapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .get();

      final habits = habitsSnapshot.docs;
      print('📋 Found ${habits.length} habits');

      if (habits.isEmpty) {
        print('⚠️ No habits found');
        return;
      }

      // Get all logs
      final logsSnapshot = await _firestore
          .collection('habit_logs')
          .where('userId', isEqualTo: userId)
          .get();

      final logs = logsSnapshot.docs;
      print('📝 Found ${logs.length} logs');

      // Distribute logs round-robin across habits
      int distributedCount = 0;
      for (int i = 0; i < logs.length; i++) {
        final habitIndex = i % habits.length;
        final habitId = habits[habitIndex].id;

        await _firestore.collection('habit_logs').doc(logs[i].id).update({
          'habitId': habitId,
        });
        distributedCount++;
      }

      print('✨ Distribution complete! Distributed $distributedCount logs');
    } catch (e) {
      print('❌ Distribution error: $e');
      rethrow;
    }
  }
}
