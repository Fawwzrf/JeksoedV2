// filepath: lib/data/models/ride_request.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequest {
  final String id;
  final String? passengerId;
  final String? driverId;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;
  final double? destLat;
  final double? destLng;
  final String? destAddress;
  final String? rideType;
  final String? paymentMethod;
  final String status;
  final double? fare;
  final double? distance;
  final double? duration;
  final String? notes;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final int? rating;
  final String? reviewComment;

  RideRequest({
    required this.id,
    this.passengerId,
    this.driverId,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.destLat,
    this.destLng,
    this.destAddress,
    this.rideType,
    this.paymentMethod,
    this.status = 'requested',
    this.fare,
    this.distance,
    this.duration,
    this.notes,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.rating,
    this.reviewComment,
  });

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
      try {
        return DateTime.parse(s);
      } catch (_) {}
      try {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(s));
      } catch (_) {}
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _parseNullableDate(dynamic v) {
    if (v == null) return null;
    final d = _parseDate(v);
    if (d.millisecondsSinceEpoch == 0) return null;
    return d;
  }

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);

    double? toDouble(dynamic x) {
      if (x == null) return null;
      if (x is double) return x;
      if (x is int) return x.toDouble();
      return double.tryParse(x.toString());
    }

    return RideRequest(
      id: (m['id'] ?? m['ride_id'] ?? m['request_id'] ?? '').toString(),
      passengerId: (m['passenger_id'] ?? m['passengerId'])?.toString(),
      driverId: (m['driver_id'] ?? m['driverId'])?.toString(),
      pickupLat: toDouble(m['pickup_lat'] ?? m['pickupLat']),
      pickupLng: toDouble(m['pickup_lng'] ?? m['pickupLng']),
      pickupAddress: (m['pickup_address'] ?? m['pickupAddress'])?.toString(),
      destLat: toDouble(m['dest_lat'] ?? m['destLat']),
      destLng: toDouble(m['dest_lng'] ?? m['destLng']),
      destAddress: (m['dest_address'] ?? m['destAddress'])?.toString(),
      rideType: (m['ride_type'] ?? m['rideType'])?.toString(),
      paymentMethod: (m['payment_method'] ?? m['paymentMethod'])?.toString(),
      status: (m['status'] ?? 'requested').toString(),
      fare: toDouble(m['fare']),
      distance: toDouble(m['distance']),
      duration: toDouble(m['duration']),
      notes: (m['notes'] ?? m['note'])?.toString(),
      createdAt: _parseDate(
        m['created_at'] ?? m['createdAt'] ?? m['createdAtIso'],
      ),
      acceptedAt: _parseNullableDate(m['accepted_at'] ?? m['acceptedAt']),
      startedAt: _parseNullableDate(m['started_at'] ?? m['startedAt']),
      completedAt: _parseNullableDate(m['completed_at'] ?? m['completedAt']),
      cancelledAt: _parseNullableDate(m['cancelled_at'] ?? m['cancelledAt']),
      rating: m['rating'] != null ? int.tryParse(m['rating'].toString()) : null,
      reviewComment: (m['review_comment'] ?? m['reviewComment'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'dest_address': destAddress,
      'ride_type': rideType,
      'payment_method': paymentMethod,
      'status': status,
      'fare': fare,
      'distance': distance,
      'duration': duration,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'rating': rating,
      'review_comment': reviewComment,
    };
  }
}
