// filepath: lib/data/models/driver_profile.dart

import '../../utils/currency_formatter.dart';

class DriverProfile {
  final String name;
  final String licensePlate;
  final String? photoUrl;
  final String balance;
  final String rating;
  final String orderCount;

  DriverProfile({
    this.name = 'Driver',
    this.licensePlate = '',
    this.photoUrl,
    this.balance = 'Rp 0',
    this.rating = '0.0',
    this.orderCount = '0',
  });

  factory DriverProfile.fromMap(Map<String, dynamic> data) {
    // Calculate average rating
    final totalRating = (data['totalRating'] ?? 0).toDouble();
    final ratingCount = (data['ratingCount'] ?? 0).toInt();
    final averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

    return DriverProfile(
      name: data['name'] ?? 'Driver',
      licensePlate: data['licensePlate'] ?? '',
      photoUrl: data['photoUrl'],
      balance: formatCurrency(data['balance'] ?? 0),
      rating: averageRating.toStringAsFixed(1),
      orderCount: '${data['completedTrips'] ?? 0}',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'licensePlate': licensePlate,
      'photoUrl': photoUrl,
      'balance': int.tryParse(balance.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      'rating': double.tryParse(rating) ?? 0.0,
      'orderCount': int.tryParse(orderCount) ?? 0,
    };
  }

  DriverProfile copyWith({
    String? name,
    String? licensePlate,
    String? photoUrl,
    String? balance,
    String? rating,
    String? orderCount,
  }) {
    return DriverProfile(
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      rating: rating ?? this.rating,
      orderCount: orderCount ?? this.orderCount,
    );
  }
}
