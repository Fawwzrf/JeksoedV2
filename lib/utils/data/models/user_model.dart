// filepath: lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? photoUrl;
  final String role;
  final String? licensePlate;
  final double totalRating;
  final int ratingCount;
  final int balance;
  final int completedTrips;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.photoUrl,
    required this.role,
    this.licensePlate,
    this.totalRating = 0.0,
    this.ratingCount = 0,
    this.balance = 0,
    this.completedTrips = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return UserModel(
      id: id ?? '',
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'passenger',
      licensePlate: data['licensePlate'],
      totalRating: (data['totalRating'] ?? 0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0).toInt(),
      balance: (data['balance'] ?? 0).toInt(),
      completedTrips: (data['completedTrips'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'licensePlate': licensePlate,
      'totalRating': totalRating,
      'ratingCount': ratingCount,
      'balance': balance,
      'completedTrips': completedTrips,
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? photoUrl,
    String? role,
    String? licensePlate,
    double? totalRating,
    int? ratingCount,
    int? balance,
    int? completedTrips,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
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
    return 'UserModel(id: $id, nama: $nama, role: $role)';
  }
}
