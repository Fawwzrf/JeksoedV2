// filepath: lib/app/modules/trip/controllers/trip_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import '../../../../data/models/ride_request.dart';
import '../../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var uiState = TripUiState().obs;
  StreamSubscription<DocumentSnapshot>? _rideRequestListener;
  StreamSubscription<Position>? _locationSubscription;

  final String rideRequestId;
  String? get currentUserId => _auth.currentUser?.uid;

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
    _rideRequestListener?.cancel();
    _locationSubscription?.cancel();
    super.onClose();
  }

  void listenToTripUpdates() {
    _rideRequestListener = _db
        .collection("ride_requests")
        .doc(rideRequestId)
        .snapshots()
        .listen(
          (snapshot) async {
            if (snapshot.exists) {
              try {
                final data = snapshot.data() as Map<String, dynamic>;
                final ride = RideRequest.fromMap(data, snapshot.id);

                // Determine if current user is driver
                final isDriver = ride.driverId == currentUserId;
                uiState.value = uiState.value.copyWith(
                  rideRequest: ride,
                  isDriver: isDriver,
                );

                // Load other user info (passenger for driver, driver for passenger)
                await loadOtherUserInfo(isDriver, ride);

                // Update route based on trip status
                await updateRouteBasedOnStatus();
              } catch (e) {
                print('Error processing trip update: $e');
              }
            }
          },
          onError: (error) {
            print('Error listening to trip updates: $error');
          },
        );
  }

  Future<void> loadOtherUserInfo(bool isDriver, RideRequest rideRequest) async {
    try {
      final otherUserId = isDriver
          ? rideRequest.passengerId
          : rideRequest.driverId;

      if (otherUserId != null && otherUserId.isNotEmpty) {
        final userDoc = await _db.collection("users").doc(otherUserId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final otherUser = UserModel.fromMap(userData, id: otherUserId);
          uiState.value = uiState.value.copyWith(otherUser: otherUser);
        }
      }
    } catch (e) {
      print('Error loading other user info: $e');
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

    _db
        .collection("ride_requests")
        .doc(rideRequestId)
        .update({
          'driverCurrentLocation': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        })
        .catchError((error) {
          print('Error updating driver location: $error');
        });
  }

  void updateTripStatus(String newStatus) {
    if (rideRequestId.isEmpty) return;

    final updateData = <String, dynamic>{'status': newStatus};

    if (newStatus == 'completed') {
      updateData['completedAt'] = FieldValue.serverTimestamp();
    }

    _db
        .collection("ride_requests")
        .doc(rideRequestId)
        .update(updateData)
        .catchError((error) {
          print('Error updating trip status: $error');
        });
  }

  void cancelTrip() {
    updateTripStatus('cancelled');
    Get.offAllNamed(Routes.driverMain);
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
