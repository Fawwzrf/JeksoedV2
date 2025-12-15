// filepath: lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String userType;
  final String? licensePlate;
  final double totalRating;
  final int ratingCount;
  final int balance;
  final int completedTrips;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.userType,
    this.licensePlate,
    this.totalRating = 0.0,
    this.ratingCount = 0,
    this.balance = 0,
    this.completedTrips = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return UserModel(
      id: id ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      userType: data['userType'] ?? 'passenger',
      licensePlate: data['licensePlate'],
      totalRating: (data['totalRating'] ?? 0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0).toInt(),
      balance: (data['balance'] ?? 0).toInt(),
      completedTrips: (data['completedTrips'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'userType': userType,
      'licensePlate': licensePlate,
      'totalRating': totalRating,
      'ratingCount': ratingCount,
      'balance': balance,
      'completedTrips': completedTrips,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? userType,
    String? licensePlate,
    double? totalRating,
    int? ratingCount,
    int? balance,
    int? completedTrips,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      licensePlate: licensePlate ?? this.licensePlate,
      totalRating: totalRating ?? this.totalRating,
      ratingCount: ratingCount ?? this.ratingCount,
      balance: balance ?? this.balance,
      completedTrips: completedTrips ?? this.completedTrips,
    );
  }

  double get averageRating {
    if (ratingCount == 0) return 0.0;
    return totalRating / ratingCount;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, userType: $userType)';
  }
}
