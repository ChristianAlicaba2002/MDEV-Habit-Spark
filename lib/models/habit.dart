class Habit {
  final String id;
  final String name;
  final bool isDone;
  final DateTime createdAt;
  final String userId;

  Habit({
    required this.id,
    required this.name,
    required this.isDone,
    required this.createdAt,
    required this.userId,
  });

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isDone': isDone,
      'createdAt': createdAt,
      'userId': userId,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    bool? isDone,
    DateTime? createdAt,
    String? userId,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
