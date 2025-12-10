// filepath: lib/data/models/ride_request.dart

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

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) {
      // treat as milliseconds if large, else seconds
      if (v > 1e12) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.fromMillisecondsSinceEpoch(v * 1000);
    }
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        final n = int.tryParse(s);
        if (n != null) {
          if (n > 1e12) return DateTime.fromMillisecondsSinceEpoch(n);
          return DateTime.fromMillisecondsSinceEpoch(n * 1000);
        }
      }
    }
    if (v is Map) {
      // handle Firestore-like map {seconds: .., nanoseconds: ..}
      final seconds = v['seconds'] ?? v['sec'];
      final nanos = v['nanoseconds'] ?? v['nanos'] ?? 0;
      if (seconds != null) {
        final s = seconds is int ? seconds : int.tryParse(seconds.toString());
        final ns = nanos is int ? nanos : int.tryParse(nanos.toString()) ?? 0;
        if (s != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            s * 1000 + (ns / 1000000).round(),
          );
        }
      }
    }
    return null;
  }

  // Factory for Supabase / JSON payloads
  factory RideRequest.fromJson(Map<String, dynamic> m) {
    final map = Map<String, dynamic>.from(m);
    LatLng parseLatLng(dynamic src, String latKey, String lngKey) {
      if (src is Map) {
        final lat = _toDouble(src['latitude'] ?? src['lat'] ?? src[latKey]);
        final lng = _toDouble(src['longitude'] ?? src['lng'] ?? src[lngKey]);
        return LatLng(lat, lng);
      }
      final lat = _toDouble(map[latKey] ?? map['pickup_lat'] ?? 0.0);
      final lng = _toDouble(map[lngKey] ?? map['pickup_lng'] ?? 0.0);
      return LatLng(lat, lng);
    }

    final pickup = parseLatLng(
      map['pickupLocation'] ?? map['pickup_location'] ?? map,
      'pickupLocation',
      'pickupLocation',
    );
    final dest = parseLatLng(
      map['destinationLocation'] ?? map['destination_location'] ?? map,
      'destinationLocation',
      'destinationLocation',
    );

    Map<String, double>? driverLoc;
    if (map['driverCurrentLocation'] != null) {
      final raw = map['driverCurrentLocation'];
      if (raw is Map) {
        driverLoc = raw.map((k, v) => MapEntry(k.toString(), _toDouble(v)));
      }
    }

    return RideRequest(
      id: (map['id'] ?? map['rideId'] ?? map['requestId'] ?? '').toString(),
      passengerId: (map['passengerId'] ?? map['passenger_id'] ?? '').toString(),
      passengerName:
          (map['passengerName'] ?? map['passenger_name'] ?? 'Unknown')
              .toString(),
      passengerRating: _toDouble(
        map['passengerRating'] ?? map['passenger_rating'] ?? 0.0,
      ),
      passengerPhone: (map['passengerPhone'] ?? map['passenger_phone'] ?? '')
          .toString(),
      pickupLocation: pickup,
      destinationLocation: dest,
      pickupAddress: (map['pickupAddress'] ?? map['pickup_address'] ?? '')
          .toString(),
      destinationAddress:
          (map['destinationAddress'] ?? map['destination_address'] ?? '')
              .toString(),
      distance: _toDouble(map['distance'] ?? 0.0),
      duration: _toInt(map['duration'] ?? 0),
      fare: _toInt(map['fare'] ?? 0),
      status: (map['status'] ?? 'pending').toString(),
      driverId: (map['driverId'] ?? map['driver_id'])?.toString(),
      createdAt: _toDateTime(
        map['createdAt'] ?? map['created_at'] ?? map['timestamp'],
      ),
      acceptedAt: _toDateTime(map['acceptedAt'] ?? map['accepted_at']),
      completedAt: _toDateTime(map['completedAt'] ?? map['completed_at']),
      rideType: (map['rideType'] ?? map['ride_type'] ?? 'motor').toString(),
      paymentMethod: (map['paymentMethod'] ?? map['payment_method'] ?? 'cash')
          .toString(),
      encodedPolyline: (map['encodedPolyline'] ?? map['encoded_polyline'])
          ?.toString(),
      rating: map['rating'] != null ? _toInt(map['rating']) : null,
      driverCurrentLocation: driverLoc,
    );
  }

  // Keep fromMap for backwards compatibility (Firestore-style)
  factory RideRequest.fromMap(Map<String, dynamic> data, String id) {
    return RideRequest.fromJson({...data, 'id': id});
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
      // use ISO string for storage in Supabase / REST
      'createdAt': createdAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
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
