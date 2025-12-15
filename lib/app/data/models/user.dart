class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double? rating;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.rating,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: UserType.values.firstWhere(
        (type) => type.name == json['user_type'],
        orElse: () => UserType.passenger,
      ),
      photoUrl: json['profile_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['is_active'] ?? true,
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType.name,
      'profile_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'rating': rating,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserType? userType,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? rating,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, userType: $userType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum UserType { passenger, driver }

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.passenger:
        return 'Passenger';
      case UserType.driver:
        return 'Driver';
    }
  }

  String get description {
    switch (this) {
      case UserType.passenger:
        return 'Book rides and travel safely';
      case UserType.driver:
        return 'Drive and earn money';
    }
  }
}
