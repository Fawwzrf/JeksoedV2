import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../data/models/ride_request.dart';
import '../../../../../data/models/driver_profile.dart';

class DriverHomeController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // Streams / subscriptions
  StreamSubscription? _positionStream;
  StreamSubscription? _rideRequestsStream;
  StreamSubscription? _profileStream;

  // Map controller (optional)
  GoogleMapController? _mapController;

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      driverLocation.value = LatLng(position.latitude, position.longitude);
      _updateDriverLocationMarker();

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position position) {
            driverLocation.value = LatLng(
              position.latitude,
              position.longitude,
            );
            _updateDriverLocationMarker();
            _updateDriverLocationInBackend(position);
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

  // helper unwrap untuk berbagai bentuk response Supabase / Postgrest
  dynamic _unwrapResponse(dynamic res) {
    try {
      // PostgrestResponse-like: has `.data`
      if (res != null) {
        // akses dynamic agar analyzer tidak compile-time error
        final dyn = res as dynamic;
        if (dyn.data != null) return dyn.data;
      }
    } catch (_) {}
    try {
      // Map-like { data: [...] }
      if (res is Map && res.containsKey('data')) return res['data'];
    } catch (_) {}
    // fallback: if it's already a List (old behavior) return it
    if (res is List) return res;
    return res;
  }

  Future<void> _updateDriverLocationInBackend(Position position) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('driver_locations').upsert({
          'user_id': userId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updated_at': DateTime.now().toIso8601String(),
        });
        // don't rely on .error; if the call throws it will be caught
      }
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  void _listenToDriverProfile() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      isLoadingProfile.value = false;
      return;
    }

    isLoadingProfile.value = true;

    // Realtime subscription to user's row; fallback to one-time fetch if realtime not needed
    _profileStream = _supabase
        .from('users:id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen(
          (List<Map<String, dynamic>> data) async {
            try {
              if (data.isNotEmpty) {
                final row = data.first;
                final totalRating =
                    (row['totalRating'] ?? row['total_rating'] ?? 0).toDouble();
                final ratingCount =
                    (row['ratingCount'] ?? row['rating_count'] ?? 0).toInt();
                final averageRating = ratingCount > 0
                    ? totalRating / ratingCount
                    : 0.0;

                driverProfile.value = DriverProfile(
                  name: row['nama'] ?? row['name'] ?? 'Driver',
                  licensePlate:
                      row['licensePlate'] ?? row['license_plate'] ?? '',
                  photoUrl: row['photoUrl'] ?? row['photo_url'],
                  balance: 'Rp${row['balance'] ?? 0}',
                  rating: averageRating.toStringAsFixed(1),
                  orderCount:
                      '${row['completedTrips'] ?? row['completed_trips'] ?? 0}',
                );
              }
            } catch (e) {
              print('Error processing profile data: $e');
            } finally {
              isLoadingProfile.value = false;
            }
          },
          onError: (err) {
            print('Error listening to driver profile: $err');
            isLoadingProfile.value = false;
          },
        );
  }

  Future<void> _checkForActiveTrip() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final res = await _supabase
          .from('ride_requests')
          .select()
          .eq('driver_id', userId)
          .inFilter('status', ['accepted', 'arrived', 'started'])
          .limit(1);

      final data = _unwrapResponse(res);
      final rows = data is List
          ? data
          : (data is Map && data['rows'] is List ? data['rows'] : null);

      if (rows is List && rows.isNotEmpty) {
        final row = Map<String, dynamic>.from(rows.first as Map);
        final ride = RideRequest.fromJson(Map<String, dynamic>.from(row));
        Get.toNamed('/trip/${ride.id}');
      }
    } catch (e) {
      print('Error checking for active trip: $e');
    }
  }

  void _startListeningForRides() {
    _rideRequestsStream?.cancel();

    _rideRequestsStream = _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen(
          (List<Map<String, dynamic>> data) {
            try {
              final raw = data
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();

              // convert and sort by created_at (newest first)
              raw.sort((a, b) {
                DateTime parse(dynamic v) {
                  if (v == null) return DateTime(1970);
                  if (v is DateTime) return v;
                  return DateTime.tryParse(v.toString()) ?? DateTime(1970);
                }

                return parse(b['created_at']).compareTo(parse(a['created_at']));
              });

              final newRequests = raw
                  .map((doc) => RideRequest.fromJson(doc))
                  .toList();

              rideRequests.value = newRequests;

              if (newRequests.isNotEmpty && popupRideRequest.value == null) {
                popupRideRequest.value = newRequests.first;
                Timer(const Duration(seconds: 30), () {
                  if (popupRideRequest.value?.id == newRequests.first.id) {
                    dismissPopup();
                  }
                });
              }
            } catch (e) {
              print('Error processing ride requests realtime: $e');
            }
          },
          onError: (err) {
            print('Error listening for rides: $err');
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

  Future<void> acceptRideRequest(RideRequest rideRequest) async {
    try {
      acceptingRideId.value = rideRequest.id;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Driver not logged in');

      final res = await _supabase
          .from('ride_requests')
          .update({
            'driver_id': userId,
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideRequest.id);

      final data = _unwrapResponse(res);
      // jika update mengembalikan list hasil, pastikan tidak kosong
      if (data is List && data.isEmpty) {
        throw Exception('No rows updated');
      }

      popupRideRequest.value = null;
      acceptingRideId.value = null;

      Get.toNamed('/trip/${rideRequest.id}');
    } catch (e) {
      acceptingRideId.value = null;
      Get.snackbar('Error', 'Failed to accept ride: $e');
    }
  }

  void rejectRideRequest(String rideId) {
    rideRequests.removeWhere((request) => request.id == rideId);
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

  void logout() async {
    await _supabase.auth.signOut();
    Get.offAllNamed('/cta');
  }
}
