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
    );
  }
}
