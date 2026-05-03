import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final bool isRecent;
  final int order;
  final String userId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.isRecent,
    required this.order,
    required this.userId,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      isRecent: map['isRecent'] ?? false,
      order: map['order'] ?? 0,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'isRecent': isRecent,
      'order': order,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({
    String? title,
    bool? isCompleted,
    bool? isRecent,
    int? order,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecent: isRecent ?? this.isRecent,
      order: order ?? this.order,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
