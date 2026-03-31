import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final bool isCompleted;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.isCompleted,
  });

  factory HabitLog.fromMap(Map<String, dynamic> map, String id) {
    return HabitLog(
      id: id,
      habitId: map['habitId'] ?? '',
      userId: map['userId'] ?? '',
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'userId': userId,
      'completedAt': Timestamp.fromDate(completedAt),
      'isCompleted': isCompleted,
    };
  }
}
