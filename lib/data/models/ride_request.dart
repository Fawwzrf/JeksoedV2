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
  final int duration; // dalam menit
  final int fare;
  final String status;
  final String? driverId;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String rideType;
  final String paymentMethod;
  final String? encodedPolyline;
  final int? rating;
  final Map<String, double>? driverCurrentLocation;
  final String? notes;

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
    this.notes,
  });

  // Helper untuk parsing angka aman
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
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory RideRequest.fromJson(Map<String, dynamic> m) {
    // Parsing LatLng dari berbagai format (nested map atau flat keys)
    LatLng parseLatLng(dynamic src, String latKey, String lngKey) {
      if (src is Map) {
        final lat = _toDouble(src['latitude'] ?? src['lat'] ?? src[latKey]);
        final lng = _toDouble(src['longitude'] ?? src['lng'] ?? src[lngKey]);
        return LatLng(lat, lng);
      }
      // Coba ambil dari root map jika src bukan map
      final lat = _toDouble(m[latKey] ?? m['${latKey}_lat'] ?? m['pickup_lat']);
      final lng = _toDouble(m[lngKey] ?? m['${lngKey}_lng'] ?? m['pickup_lng']);
      return LatLng(lat, lng);
    }

    final pickup = parseLatLng(
      m['pickupLocation'] ?? m['pickup_location'] ?? m,
      'pickup_lat',
      'pickup_lng',
    );

    final dest = parseLatLng(
      m['destinationLocation'] ?? m['destination_location'] ?? m,
      'dest_lat',
      'dest_lng',
    );

    Map<String, double>? driverLoc;
    if (m['driver_current_location'] != null ||
        m['driverCurrentLocation'] != null) {
      final raw = m['driver_current_location'] ?? m['driverCurrentLocation'];
      if (raw is Map) {
        driverLoc = {
          'latitude': _toDouble(raw['latitude'] ?? raw['lat']),
          'longitude': _toDouble(raw['longitude'] ?? raw['lng']),
        };
      }
    }

    return RideRequest(
      id: (m['id'] ?? '').toString(),
      passengerId: (m['passenger_id'] ?? m['passengerId'] ?? '').toString(),
      passengerName: (m['passenger_name'] ?? m['passengerName'] ?? 'Penumpang')
          .toString(),
      passengerRating: _toDouble(m['passenger_rating'] ?? m['passengerRating']),
      passengerPhone: (m['passenger_phone'] ?? m['passengerPhone'] ?? '')
          .toString(),
      pickupLocation: pickup,
      destinationLocation: dest,
      pickupAddress: (m['pickup_address'] ?? m['pickupAddress'] ?? '')
          .toString(),
      destinationAddress:
          (m['dest_address'] ??
                  m['destAddress'] ??
                  m['destinationAddress'] ??
                  '')
              .toString(),
      distance: _toDouble(m['distance']),
      duration: _toInt(m['duration']),
      fare: _toInt(m['fare']),
      status: (m['status'] ?? 'pending').toString(),
      driverId: (m['driver_id'] ?? m['driverId'])?.toString(),
      createdAt: _toDateTime(m['created_at'] ?? m['createdAt']),
      acceptedAt: _toDateTime(m['accepted_at'] ?? m['acceptedAt']),
      completedAt: _toDateTime(m['completed_at'] ?? m['completedAt']),
      rideType: (m['ride_type'] ?? m['rideType'] ?? 'motor').toString(),
      paymentMethod: (m['payment_method'] ?? m['paymentMethod'] ?? 'cash')
          .toString(),
      encodedPolyline: (m['encoded_polyline'] ?? m['encodedPolyline'])
          ?.toString(),
      rating: m['rating'] != null ? _toInt(m['rating']) : null,
      driverCurrentLocation: driverLoc,
      notes: (m['notes'] ?? '').toString(),
    );
  }

  // Helper untuk kompatibilitas
  factory RideRequest.fromMap(Map<String, dynamic> data, String id) {
    return RideRequest.fromJson({...data, 'id': id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'passenger_name': passengerName,
      'pickup_lat': pickupLocation.latitude,
      'pickup_lng': pickupLocation.longitude,
      'pickup_address': pickupAddress,
      'dest_lat': destinationLocation.latitude,
      'dest_lng': destinationLocation.longitude,
      'dest_address': destinationAddress,
      'distance': distance,
      'duration': duration,
      'fare': fare,
      'status': status,
      'driver_id': driverId,
      'created_at': createdAt?.toIso8601String(),
      'ride_type': rideType,
      'payment_method': paymentMethod,
      'encoded_polyline': encodedPolyline,
      'notes': notes,
    };
  }
}
