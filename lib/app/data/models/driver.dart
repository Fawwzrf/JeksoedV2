// filepath: lib/app/data/models/driver.dart

class Driver {
  final String id;
  final String userId;
  final VehicleInfo? vehicleInfo;
  final DriverDocuments? documents;
  final DriverStatus status;
  final double rating;
  final int totalTrips;
  final bool isOnline;
  final LocationData? currentLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.userId,
    this.vehicleInfo,
    this.documents,
    required this.status,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.isOnline = false,
    this.currentLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      vehicleInfo: json['vehicle_info'] != null
          ? VehicleInfo.fromJson(json['vehicle_info'])
          : null,
      documents: json['documents'] != null
          ? DriverDocuments.fromJson(json['documents'])
          : null,
      status: DriverStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => DriverStatus.pending,
      ),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalTrips: json['total_trips'] ?? 0,
      isOnline: json['is_online'] ?? false,
      currentLocation: json['current_location'] != null
          ? LocationData.fromJson(json['current_location'])
          : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_info': vehicleInfo?.toJson(),
      'documents': documents?.toJson(),
      'status': status.name,
      'rating': rating,
      'total_trips': totalTrips,
      'is_online': isOnline,
      'current_location': currentLocation?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Driver copyWith({
    String? id,
    String? userId,
    VehicleInfo? vehicleInfo,
    DriverDocuments? documents,
    DriverStatus? status,
    double? rating,
    int? totalTrips,
    bool? isOnline,
    LocationData? currentLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      isOnline: isOnline ?? this.isOnline,
      currentLocation: currentLocation ?? this.currentLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VehicleInfo {
  final String make;
  final String model;
  final String year;
  final String color;
  final String licensePlate;
  final VehicleType type;
  final String? vin;
  final List<String>? photos;

  VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.type,
    this.vin,
    this.photos,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      color: json['color'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      type: VehicleType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => VehicleType.car,
      ),
      vin: json['vin'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'type': type.name,
      'vin': vin,
      'photos': photos,
    };
  }
}

class DriverDocuments {
  final DocumentInfo? driverLicense;
  final DocumentInfo? vehicleRegistration;
  final DocumentInfo? insurance;
  final DocumentInfo? backgroundCheck;

  DriverDocuments({
    this.driverLicense,
    this.vehicleRegistration,
    this.insurance,
    this.backgroundCheck,
  });

  factory DriverDocuments.fromJson(Map<String, dynamic> json) {
    return DriverDocuments(
      driverLicense: json['driver_license'] != null
          ? DocumentInfo.fromJson(json['driver_license'])
          : null,
      vehicleRegistration: json['vehicle_registration'] != null
          ? DocumentInfo.fromJson(json['vehicle_registration'])
          : null,
      insurance: json['insurance'] != null
          ? DocumentInfo.fromJson(json['insurance'])
          : null,
      backgroundCheck: json['background_check'] != null
          ? DocumentInfo.fromJson(json['background_check'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_license': driverLicense?.toJson(),
      'vehicle_registration': vehicleRegistration?.toJson(),
      'insurance': insurance?.toJson(),
      'background_check': backgroundCheck?.toJson(),
    };
  }
}

class DocumentInfo {
  final String number;
  final DateTime expiryDate;
  final String? imageUrl;
  final DocumentStatus status;
  final String? rejectionReason;

  DocumentInfo({
    required this.number,
    required this.expiryDate,
    this.imageUrl,
    required this.status,
    this.rejectionReason,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      number: json['number'] ?? '',
      expiryDate: DateTime.parse(
        json['expiry_date'] ?? DateTime.now().toIso8601String(),
      ),
      imageUrl: json['image_url'],
      status: DocumentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => DocumentStatus.pending,
      ),
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'expiry_date': expiryDate.toIso8601String(),
      'image_url': imageUrl,
      'status': status.name,
      'rejection_reason': rejectionReason,
    };
  }
}

enum VehicleType { car, motorcycle, van, truck }

enum DriverStatus { pending, underReview, approved, rejected, suspended }

enum DocumentStatus { pending, approved, rejected }

// Import LocationData from ride_request.dart
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayName => address ?? '$latitude, $longitude';
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.van:
        return 'Van';
      case VehicleType.truck:
        return 'Truck';
    }
  }
}

extension DriverStatusExtension on DriverStatus {
  String get displayName {
    switch (this) {
      case DriverStatus.pending:
        return 'Pending Verification';
      case DriverStatus.underReview:
        return 'Under Review';
      case DriverStatus.approved:
        return 'Approved';
      case DriverStatus.rejected:
        return 'Rejected';
      case DriverStatus.suspended:
        return 'Suspended';
    }
  }
}

extension DocumentStatusExtension on DocumentStatus {
  String get displayName {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pending Review';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
    }
  }
}
