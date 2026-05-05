class Habit {
  final String id;
  final String name;
  final bool isDone;
  final DateTime createdAt;
  final String userId;
  final String? icon;
  final String? imageUrl;
  final String habitType; // 'checkbox', 'distance', 'time', 'weight'
  final double? targetValue;
  final String? unit;
  final String routine; // 'Morning', 'Afternoon', 'Evening', 'Midnight'
  final String category; // 'Fitness', 'Productivity', 'Wellness', etc.

  Habit({
    required this.id,
    required this.name,
    required this.isDone,
    required this.createdAt,
    required this.userId,
    this.icon,
    this.imageUrl,
    this.habitType = 'checkbox',
    this.targetValue,
    this.unit,
    this.routine = 'General',
    this.category = 'General',
  });

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      isDone: (map['isDone'] as bool?) ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
      userId: map['userId'] ?? '',
      icon: map['icon'] as String?,
      imageUrl: map['imageUrl'] as String?,
      habitType: map['habitType'] ?? 'checkbox',
      targetValue: map['targetValue']?.toDouble(),
      unit: map['unit'] as String?,
      routine: map['routine'] ?? 'General',
      category: map['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isDone': isDone,
      'createdAt': createdAt,
      'userId': userId,
      if (icon != null) 'icon': icon,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'habitType': habitType,
      if (targetValue != null) 'targetValue': targetValue,
      if (unit != null) 'unit': unit,
      'routine': routine,
      'category': category,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    bool? isDone,
    DateTime? createdAt,
    String? userId,
    String? icon,
    String? imageUrl,
    String? habitType,
    double? targetValue,
    String? unit,
    String? routine,
    String? category,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      habitType: habitType ?? this.habitType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      routine: routine ?? this.routine,
      category: category ?? this.category,
    );
  }
}
