class RideRequest {
  final String id;
  final String passengerId;
  final String? driverId;
  final LocationData pickupLocation;
  final LocationData destinationLocation;
  final RideStatus status;
  final RideType rideType;
  final double estimatedDistance;
  final double estimatedDuration;
  final double estimatedFare;
  final double? actualFare;
  final DateTime requestTime;
  final DateTime? acceptedTime;
  final DateTime? startTime;
  final DateTime? completedTime;
  final String? notes;
  final PaymentMethod paymentMethod;
  final RideRating? rating;

  RideRequest({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    required this.rideType,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.estimatedFare,
    this.actualFare,
    required this.requestTime,
    this.acceptedTime,
    this.startTime,
    this.completedTime,
    this.notes,
    required this.paymentMethod,
    this.rating,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] ?? '',
      passengerId: json['passenger_id'] ?? '',
      driverId: json['driver_id'],
      pickupLocation: LocationData.fromJson(json['pickup_location'] ?? {}),
      destinationLocation: LocationData.fromJson(
        json['destination_location'] ?? {},
      ),
      status: RideStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => RideStatus.requested,
      ),
      rideType: RideType.values.firstWhere(
        (type) => type.name == json['ride_type'],
        orElse: () => RideType.regular,
      ),
      estimatedDistance: json['estimated_distance']?.toDouble() ?? 0.0,
      estimatedDuration: json['estimated_duration']?.toDouble() ?? 0.0,
      estimatedFare: json['estimated_fare']?.toDouble() ?? 0.0,
      actualFare: json['actual_fare']?.toDouble(),
      requestTime: DateTime.parse(
        json['request_time'] ?? DateTime.now().toIso8601String(),
      ),
      acceptedTime: json['accepted_time'] != null
          ? DateTime.parse(json['accepted_time'])
          : null,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      completedTime: json['completed_time'] != null
          ? DateTime.parse(json['completed_time'])
          : null,
      notes: json['notes'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      rating: json['rating'] != null
          ? RideRating.fromJson(json['rating'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'pickup_location': pickupLocation.toJson(),
      'destination_location': destinationLocation.toJson(),
      'status': status.name,
      'ride_type': rideType.name,
      'estimated_distance': estimatedDistance,
      'estimated_duration': estimatedDuration,
      'estimated_fare': estimatedFare,
      'actual_fare': actualFare,
      'request_time': requestTime.toIso8601String(),
      'accepted_time': acceptedTime?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'completed_time': completedTime?.toIso8601String(),
      'notes': notes,
      'payment_method': paymentMethod.name,
      'rating': rating?.toJson(),
    };
  }

  RideRequest copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    LocationData? pickupLocation,
    LocationData? destinationLocation,
    RideStatus? status,
    RideType? rideType,
    double? estimatedDistance,
    double? estimatedDuration,
    double? estimatedFare,
    double? actualFare,
    DateTime? requestTime,
    DateTime? acceptedTime,
    DateTime? startTime,
    DateTime? completedTime,
    String? notes,
    PaymentMethod? paymentMethod,
    RideRating? rating,
  }) {
    return RideRequest(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      status: status ?? this.status,
      rideType: rideType ?? this.rideType,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      requestTime: requestTime ?? this.requestTime,
      acceptedTime: acceptedTime ?? this.acceptedTime,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rating: rating ?? this.rating,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeId;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeId,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      placeId: json['place_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'place_id': placeId,
    };
  }
}

class RideRating {
  final int rating;
  final String? comment;
  final DateTime createdAt;

  RideRating({required this.rating, this.comment, required this.createdAt});

  factory RideRating.fromJson(Map<String, dynamic> json) {
    return RideRating(
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum RideStatus {
  requested,
  accepted,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

enum RideType { regular, premium, shared }

enum PaymentMethod { cash, creditCard, digitalWallet }

extension RideStatusExtension on RideStatus {
  String get displayName {
    switch (this) {
      case RideStatus.requested:
        return 'Requested';
      case RideStatus.accepted:
        return 'Accepted';
      case RideStatus.driverArriving:
        return 'Driver Arriving';
      case RideStatus.inProgress:
        return 'In Progress';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case RideStatus.requested:
        return 'Looking for a driver';
      case RideStatus.accepted:
        return 'Driver found and on the way';
      case RideStatus.driverArriving:
        return 'Driver is arriving at pickup location';
      case RideStatus.inProgress:
        return 'Trip in progress';
      case RideStatus.completed:
        return 'Trip completed successfully';
      case RideStatus.cancelled:
        return 'Trip was cancelled';
    }
  }
}
