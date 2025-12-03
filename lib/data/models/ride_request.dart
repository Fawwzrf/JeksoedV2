// filepath: lib/data/models/ride_request.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequest {
  final String id;
  final String passengerId;
  final String passengerName;
  final double passengerRating;
  final String passengerPhone;
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final String pickupAddress;
  final String destinationAddress;
  final double distance;
  final int duration; // in minutes
  final int fare;
  final String status; // pending, accepted, rejected, completed, cancelled
  final String? driverId;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String rideType; // motor, car, etc.
  final String paymentMethod;
  final String? encodedPolyline;
  final int? rating;
  final Map<String, double>? driverCurrentLocation;

  RideRequest({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.passengerRating,
    required this.passengerPhone,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.distance,
    required this.duration,
    required this.fare,
    required this.status,
    this.driverId,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
    required this.rideType,
    required this.paymentMethod,
    this.encodedPolyline,
    this.rating,
    this.driverCurrentLocation,
  });

  factory RideRequest.fromMap(Map<String, dynamic> data, String id) {
    return RideRequest(
      id: id,
      passengerId: data['passengerId'] ?? '',
      passengerName: data['passengerName'] ?? 'Unknown',
      passengerRating: (data['passengerRating'] ?? 0.0).toDouble(),
      passengerPhone: data['passengerPhone'] ?? '',
      pickupLocation: LatLng(
        (data['pickupLocation']['latitude'] ?? 0.0).toDouble(),
        (data['pickupLocation']['longitude'] ?? 0.0).toDouble(),
      ),
      destinationLocation: LatLng(
        (data['destinationLocation']['latitude'] ?? 0.0).toDouble(),
        (data['destinationLocation']['longitude'] ?? 0.0).toDouble(),
      ),
      pickupAddress: data['pickupAddress'] ?? '',
      destinationAddress: data['destinationAddress'] ?? '',
      distance: (data['distance'] ?? 0.0).toDouble(),
      duration: (data['duration'] ?? 0).toInt(),
      fare: (data['fare'] ?? 0).toInt(),
      status: data['status'] ?? 'pending',
      driverId: data['driverId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rideType: data['rideType'] ?? 'motor',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      encodedPolyline: data['encodedPolyline'],
      rating: (data['rating'] as int?),
      driverCurrentLocation: data['driverCurrentLocation'] != null
          ? Map<String, double>.from(data['driverCurrentLocation'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerRating': passengerRating,
      'passengerPhone': passengerPhone,
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude,
      },
      'destinationLocation': {
        'latitude': destinationLocation.latitude,
        'longitude': destinationLocation.longitude,
      },
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'distance': distance,
      'duration': duration,
      'fare': fare,
      'status': status,
      'driverId': driverId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'rideType': rideType,
      'paymentMethod': paymentMethod,
      'encodedPolyline': encodedPolyline,
      'rating': rating,
      'driverCurrentLocation': driverCurrentLocation,
    };
  }

  RideRequest copyWith({
    String? id,
    String? passengerId,
    String? passengerName,
    double? passengerRating,
    String? passengerPhone,
    LatLng? pickupLocation,
    LatLng? destinationLocation,
    String? pickupAddress,
    String? destinationAddress,
    double? distance,
    int? duration,
    int? fare,
    String? status,
    String? driverId,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? rideType,
    String? paymentMethod,
    String? encodedPolyline,
    int? rating,
    Map<String, double>? driverCurrentLocation,
  }) {
    return RideRequest(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerRating: passengerRating ?? this.passengerRating,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      rideType: rideType ?? this.rideType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      rating: rating ?? this.rating,
      driverCurrentLocation:
          driverCurrentLocation ?? this.driverCurrentLocation,
    );
  }

  @override
  String toString() {
    return 'RideRequest(id: $id, passengerName: $passengerName, status: $status, fare: $fare)';
  }
}
