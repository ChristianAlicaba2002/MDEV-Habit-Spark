import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final bool isCompleted;
  final double? distance; // Distance in km
  final int? durationSeconds; // Duration in seconds
  final String? notes;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.isCompleted,
    this.distance,
    this.durationSeconds,
    this.notes,
  });

  factory HabitLog.fromMap(Map<String, dynamic> map, String id) {
    return HabitLog(
      id: id,
      habitId: map['habitId'] ?? '',
      userId: map['userId'] ?? '',
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      distance: map['distance']?.toDouble(),
      durationSeconds: map['durationSeconds'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'userId': userId,
      'completedAt': Timestamp.fromDate(completedAt),
      'isCompleted': isCompleted,
      if (distance != null) 'distance': distance,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (notes != null) 'notes': notes,
    };
  }
}
