import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_models.dart';

class PlacesService {
  final String apiKey;

  PlacesService({required this.apiKey});

  /// Search places using Google Places Autocomplete API
  Future<List<PlacePrediction>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:id&language=id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((json) => PlacePrediction.fromJson(json))
              .toList();
        } else {
          print('Places API error: ${data['status']}');
          return [];
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Get place details by placeId
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=place_id,name,formatted_address,geometry&language=id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        } else {
          print('Place Details API error: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }
}
