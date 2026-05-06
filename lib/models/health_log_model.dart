import 'package:cloud_firestore/cloud_firestore.dart';

class HealthLog {
  final String? id;
  final String userId;
  final String type; // steps, calories, distance, sleep
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // For speed, duration, etc.

  HealthLog({
    this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });

  factory HealthLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HealthLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}
