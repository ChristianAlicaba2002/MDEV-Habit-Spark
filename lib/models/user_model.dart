class UserModel {
  final String uuid;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String email;
  final String password;
  final String photoUrl;
  final String createdAt;
  final bool hasSeenOnboarding;
  final String? username;
  final double? height;
  final double? weight;
  final int? age;

  UserModel({
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.password,
    required this.photoUrl,
    required this.createdAt,
    this.hasSeenOnboarding = false,
    this.username,
    this.height,
    this.weight,
    this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'email': email,
      'password': password,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'hasSeenOnboarding': hasSeenOnboarding,
      if (username != null) 'username': username,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (age != null) 'age': age,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uuid: documentId,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      birthDate: map['birthDate'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: map['createdAt'] ?? '',
      hasSeenOnboarding: map['hasSeenOnboarding'] ?? false,
      username: map['username'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      age: map['age'] as int?,
    );
  }
}
