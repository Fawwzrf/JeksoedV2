import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
      fullText: json['description'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final LatLng location;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      location: LatLng(
        location['lat']?.toDouble() ?? 0.0,
        location['lng']?.toDouble() ?? 0.0,
      ),
    );
  }
}

class SavedPlace {
  final String title;
  final String address;
  final String distance;
  final String placeId;

  SavedPlace({
    required this.title,
    required this.address,
    required this.distance,
    required this.placeId,
  });
}
