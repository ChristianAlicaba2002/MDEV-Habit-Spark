class Habit {
  final String id;
  final String name;
  final bool isDone;
  final DateTime createdAt;
  final String userId;
  final String? icon; // Icon name to store

  Habit({
    required this.id,
    required this.name,
    required this.isDone,
    required this.createdAt,
    required this.userId,
    this.icon,
  });

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
      userId: map['userId'] ?? '',
      icon: map['icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isDone': isDone,
      'createdAt': createdAt,
      'userId': userId,
      if (icon != null) 'icon': icon,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    bool? isDone,
    DateTime? createdAt,
    String? userId,
    String? icon,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      icon: icon ?? this.icon,
    );
  }
}
