import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String userId;
  final String trainingName;
  final DateTime date;
  final String startTime; // Format: "HH:mm"
  final String endTime;   // Format: "HH:mm"
  final String location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.userId,
    required this.trainingName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'trainingName': trainingName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      trainingName: map['trainingName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      location: map['location'] ?? '',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method
  CalendarEvent copyWith({
    String? id,
    String? userId,
    String? trainingName,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainingName: trainingName ?? this.trainingName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
