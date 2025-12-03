import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../data/models/ride_request.dart';
import '../../../../../data/models/driver_profile.dart';

class DriverHomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  var isOnline = true.obs;
  var driverLocation = const LatLng(
    -7.4299,
    109.2479,
  ).obs; // Default Purwokerto
  var driverProfile = DriverProfile().obs;
  var isLoadingProfile = true.obs;
  var rideRequests = <RideRequest>[].obs;
  var popupRideRequest = Rxn<RideRequest>();
  var showOfflineDialog = false.obs;
  var acceptingRideId = Rxn<String>();
  var markers = <Marker>[].obs;

  // Map and Location
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<QuerySnapshot>? _rideRequestsStream;
  StreamSubscription<DocumentSnapshot>? _profileStream;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
    _listenToDriverProfile();
    _checkForActiveTrip();
    if (isOnline.value) {
      _startListeningForRides();
    }
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _rideRequestsStream?.cancel();
    _profileStream?.cancel();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _initializeLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      driverLocation.value = LatLng(position.latitude, position.longitude);
      _updateDriverLocationMarker();

      // Listen to location changes
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
            ),
          ).listen((Position position) {
            driverLocation.value = LatLng(
              position.latitude,
              position.longitude,
            );
            _updateDriverLocationMarker();
            _updateDriverLocationInFirestore(position);
          });
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e');
    }
  }

  void _updateDriverLocationMarker() {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: driverLocation.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );
  }

  Future<void> _updateDriverLocationInFirestore(Position position) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('driver_locations').doc(userId).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  void _listenToDriverProfile() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    isLoadingProfile.value = true;
    _profileStream = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data() as Map<String, dynamic>;

              // Calculate average rating
              final totalRating = (data['totalRating'] ?? 0).toDouble();
              final ratingCount = (data['ratingCount'] ?? 0).toInt();
              final averageRating = ratingCount > 0
                  ? totalRating / ratingCount
                  : 0.0;

              driverProfile.value = DriverProfile(
                name: data['nama'] ?? 'Driver',
                licensePlate: data['licensePlate'] ?? '',
                photoUrl: data['photoUrl'],
                balance: 'Rp${data['balance'] ?? 0}',
                rating: averageRating.toStringAsFixed(1),
                orderCount: '${data['completedTrips'] ?? 0}',
              );
            }
            isLoadingProfile.value = false;
          },
          onError: (error) {
            print('Error listening to driver profile: $error');
            isLoadingProfile.value = false;
          },
        );
  }

  Future<void> _checkForActiveTrip() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('ride_requests')
          .where('driverId', isEqualTo: userId)
          .where('status', whereIn: ['accepted', 'arrived', 'started'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final rideRequestId = snapshot.docs.first.id;
        // Navigate to active trip
        Get.toNamed('/trip/$rideRequestId');
      }
    } catch (e) {
      print('Error checking for active trip: $e');
    }
  }

  void _startListeningForRides() {
    _rideRequestsStream?.cancel();
    _rideRequestsStream = _firestore
        .collection('ride_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final newRequests = snapshot.docs.map((doc) {
              final data = doc.data();
              return RideRequest.fromMap(data, doc.id);
            }).toList();

            // Update ride requests
            rideRequests.value = newRequests;

            // Show popup for new requests
            if (newRequests.isNotEmpty && popupRideRequest.value == null) {
              popupRideRequest.value = newRequests.first;

              // Auto dismiss after 30 seconds
              Timer(const Duration(seconds: 30), () {
                if (popupRideRequest.value?.id == newRequests.first.id) {
                  dismissPopup();
                }
              });
            }
          },
          onError: (error) {
            print('Error listening for rides: $error');
          },
        );
  }

  void _stopListeningForRides() {
    _rideRequestsStream?.cancel();
    rideRequests.clear();
    popupRideRequest.value = null;
  }

  void toggleOnlineStatus() {
    if (isOnline.value) {
      showOfflineDialog.value = true;
    } else {
      isOnline.value = true;
      _startListeningForRides();
    }
  }

  void confirmGoOffline() {
    isOnline.value = false;
    showOfflineDialog.value = false;
    _stopListeningForRides();
  }

  void dismissOfflineDialog() {
    showOfflineDialog.value = false;
  }

  void acceptRideRequest(RideRequest rideRequest) async {
    try {
      acceptingRideId.value = rideRequest.id;
      final userId = _auth.currentUser?.uid;

      if (userId == null) throw Exception('Driver not logged in');

      // Update ride request with driver info
      await _firestore.collection('ride_requests').doc(rideRequest.id).update({
        'driverId': userId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Clear popup
      popupRideRequest.value = null;
      acceptingRideId.value = null;

      // Navigate to trip screen
      Get.toNamed('/trip/${rideRequest.id}');
    } catch (e) {
      acceptingRideId.value = null;
      Get.snackbar('Error', 'Failed to accept ride: $e');
    }
  }

  void rejectRideRequest(String rideId) {
    // Remove from local list
    rideRequests.removeWhere((request) => request.id == rideId);

    // Clear popup if it's the same request
    if (popupRideRequest.value?.id == rideId) {
      popupRideRequest.value = null;
    }
  }

  void dismissPopup() {
    popupRideRequest.value = null;
  }

  void onNotificationClick() {
    Get.toNamed('/all-orders');
  }

  void logout() {
    _auth.signOut();
    Get.offAllNamed('/cta');
  }
}
