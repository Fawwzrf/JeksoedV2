import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/models/ride_request.dart';
import '../../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

sealed class TripNavEvent {
  static const navigateToHome = 'navigateToHome';
  static const navigateToRating = 'navigateToRating';
  static const navigateToTripCompleted = 'navigateToTripCompleted';
}

class TripUiState {
  final RideRequest? rideRequest;
  final List<LatLng> dynamicPolylinePoints;
  final bool isDriver;
  final UserModel? otherUser;

  TripUiState({
    this.rideRequest,
    this.dynamicPolylinePoints = const [],
    this.isDriver = false,
    this.otherUser,
  });

  TripUiState copyWith({
    RideRequest? rideRequest,
    List<LatLng>? dynamicPolylinePoints,
    bool? isDriver,
    UserModel? otherUser,
  }) {
    return TripUiState(
      rideRequest: rideRequest ?? this.rideRequest,
      dynamicPolylinePoints:
          dynamicPolylinePoints ?? this.dynamicPolylinePoints,
      isDriver: isDriver ?? this.isDriver,
      otherUser: otherUser ?? this.otherUser,
    );
  }
}

class TripController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var uiState = TripUiState().obs;
  StreamSubscription? _rideSubscription;
  StreamSubscription<Position>? _locationSubscription;

  final String rideRequestId;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  TripController({required this.rideRequestId});

  @override
  void onInit() {
    super.onInit();
    if (rideRequestId.isNotEmpty) {
      listenToTripUpdates();
    }
  }

  @override
  void onClose() {
    _rideSubscription?.cancel();
    _locationSubscription?.cancel();
    super.onClose();
  }

  void listenToTripUpdates() {
    // Menggunakan Stream Supabase
    _rideSubscription = _supabase
        .from("ride_requests")
        .stream(primaryKey: ['id'])
        .eq('id', rideRequestId)
        .listen((List<Map<String, dynamic>> data) async {
          if (data.isNotEmpty) {
            try {
              final rideData = data.first;
              final ride = RideRequest.fromJson(rideData); // Gunakan fromJson

              final isDriver = ride.driverId == currentUserId;
              uiState.value = uiState.value.copyWith(
                rideRequest: ride,
                isDriver: isDriver,
              );

              await loadOtherUserInfo(isDriver, ride);
              // await updateRouteBasedOnStatus(); // (Implementasi logika peta)
            } catch (e) {
              print('Error processing trip update: $e');
            }
          }
        });
  }

  Future<void> loadOtherUserInfo(bool isDriver, RideRequest rideRequest) async {
    final otherUserId = isDriver
        ? rideRequest.passengerId
        : rideRequest.driverId;
    if (otherUserId != null) {
      final userData = await _supabase
          .from("users")
          .select()
          .eq("id", otherUserId)
          .maybeSingle();

      if (userData != null) {
        final otherUser = UserModel.fromMap(userData, id: otherUserId);
        uiState.value = uiState.value.copyWith(otherUser: otherUser);
      }
    }
  }

  Future<void> updateRouteBasedOnStatus() async {
    final request = uiState.value.rideRequest;
    if (request == null) return;

    try {
      // Extract locations
      final driverLocation =
          request.driverId != null && request.driverCurrentLocation != null
          ? LatLng(
              request.driverCurrentLocation!['latitude'] ?? 0.0,
              request.driverCurrentLocation!['longitude'] ?? 0.0,
            )
          : null;

      final pickupLocation = LatLng(
        request.pickupLocation.latitude,
        request.pickupLocation.longitude,
      );

      final destinationLocation = LatLng(
        request.destinationLocation.latitude,
        request.destinationLocation.longitude,
      );

      LatLng? origin;
      LatLng? destination;

      switch (request.status) {
        case 'accepted':
        case 'arrived':
          // Driver going to pickup location
          origin = driverLocation;
          destination = pickupLocation;
          break;
        case 'started':
          // Trip in progress: pickup to destination
          origin = pickupLocation;
          destination = destinationLocation;
          break;
        case 'completed':
          // Show full route from pickup to destination
          origin = pickupLocation;
          destination = destinationLocation;
          break;
      } // Use encoded polyline if available, otherwise use simple route
      List<LatLng> polylinePoints = [];
      if (request.encodedPolyline != null &&
          request.encodedPolyline!.isNotEmpty) {
        final decoded = decodePolyline(request.encodedPolyline!);
        polylinePoints = decoded
            .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
            .toList();
      } else if (origin != null && destination != null) {
        // Simple straight line route (in real app, use Directions API)
        polylinePoints = [origin, destination];
      }

      uiState.value = uiState.value.copyWith(
        dynamicPolylinePoints: polylinePoints,
      );
    } catch (e) {
      print('Error updating route: $e');
    }
  }

  void startLocationUpdates() async {
    if (!uiState.value.isDriver) return;

    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            updateDriverLocation(position);
          },
          onError: (error) {
            print('Location stream error: $error');
          },
        );
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void updateDriverLocation(Position position) {
    if (rideRequestId.isEmpty) return;

    _supabase
        .from("ride_requests")
        .update({
          'driver_current_location': {
            // Pastikan kolom di DB snake_case atau jsonb
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        })
        .eq('id', rideRequestId)
        .then((_) {})
        .catchError((error) => print('Error updating loc: $error'));
  }

  void updateTripStatus(String newStatus) {
    if (rideRequestId.isEmpty) return;

    final updateData = <String, dynamic>{'status': newStatus};
    if (newStatus == 'completed') {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    }

    _supabase.from("ride_requests").update(updateData).eq('id', rideRequestId);
  }

  void cancelTrip() {
    updateTripStatus('cancelled');
    if (uiState.value.isDriver) {
      Get.offAllNamed(Routes.driverMain);
    } else {
      Get.offAllNamed(Routes.passengerMain);
    }
  }

  void confirmPaymentAndFinishTrip() {
    Get.toNamed('/trip-completed/$rideRequestId');
  }

  void navigateToChat() {
    Get.toNamed('/chat/$rideRequestId');
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
