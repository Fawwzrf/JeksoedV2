import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jeksoedv2/app/data/services/ride_service.dart';
import 'package:jeksoedv2/data/services/places_service.dart';
import 'package:jeksoedv2/data/models/place_models.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

enum OrderStage { search, pickupConfirm, routeConfirm, findingDriver }

class CreateOrderController extends GetxController {
  static const String googleMapsApiKey =
      'AIzaSyAuyoAFHTVJRA6WKBRGnDc1mQ1ZQk7pl2A';

  final RideService _rideService = Get.find<RideService>();
  late final PlacesService _placesService;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Controllers
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final notesController = TextEditingController();

  // Google Maps
  GoogleMapController? mapController;
  final cameraPosition = const CameraPosition(
    target: LatLng(-7.4242, 109.2303),
    zoom: 14,
  ).obs;

  // State
  final isLoading = false.obs;
  final isFormValid = false.obs;
  final currentStage = OrderStage.search.obs;
  final selectedVehicleType = 'motor'.obs;

  // Price & Route Info
  final estimatedPrice = 0.0.obs;
  final estimatedDistance = 0.0.obs;
  final estimatedDuration = 0.obs;
  String? encodedPolyline;
  final routePolylinePoints = <LatLng>[].obs;

  // Location & Search
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  LatLng? pickupLatLng;
  LatLng? destLatLng;
  final pickupQuery = 'Lokasi saat ini'.obs;
  final destinationQuery = ''.obs;
  final pickupAddress = ''.obs;
  final destinationAddress = ''.obs;

  final predictions = <PlacePrediction>[].obs;
  final savedPlaces = <SavedPlace>[].obs;
  final isSearchingPickup = false.obs;
  final isSearchingDestination = false.obs;
  final isRouteLoading = false.obs;

  Timer? _searchDebounce;

  // User & Driver
  final userPhotoUrl = Rx<String?>(null);
  final driverLocations = <LatLng>[].obs;
  final activeRideRequestId = Rx<String?>(null);

  StreamSubscription? _rideStatusSubscription;

  // Vehicle Types
  final vehicleTypes = [
    {
      'type': 'motor',
      'name': 'JekMotor',
      'icon': Icons.motorcycle,
      'pricePerKm': 2500,
      'description': 'Cepat dan terjangkau',
    },
    {
      'type': 'mobil',
      'name': 'JekMobil',
      'icon': Icons.directions_car,
      'pricePerKm': 4000,
      'description': 'Lebih nyaman dan luas',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _placesService = PlacesService(apiKey: googleMapsApiKey);

    if (vehicleTypes.isNotEmpty) {
      selectedVehicleType.value = vehicleTypes[0]['type'] as String;
    }

    _initializeUserLocation();
    _fetchUserData();
    _loadSavedPlaces();
    _loadDummyDrivers();
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    _searchDebounce?.cancel();
    _rideStatusSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  // --- INITIALIZATION ---

  Future<void> _initializeUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      userLocation.value = LatLng(position.latitude, position.longitude);
      pickupLatLng = userLocation.value;
      pickupQuery.value = 'Lokasi saat ini';
      pickupAddress.value = 'Menggunakan lokasi Anda saat ini';

      if (mapController != null) {
        animateCameraToPosition(userLocation.value!);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('users')
          .select('photo_url')
          .eq('id', userId)
          .single();

      if (response['photo_url'] != null) {
        userPhotoUrl.value = response['photo_url'];
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _loadSavedPlaces() {
    savedPlaces.value = [
      SavedPlace(
        placeId: '1',
        title: 'Rumah',
        address: 'Jl. Example No. 123',
        distance: '2.5 km dari lokasi Anda',
      ),
      SavedPlace(
        placeId: '2',
        title: 'Kantor',
        address: 'Jl. Work Street No. 456',
        distance: '5.2 km dari lokasi Anda',
      ),
    ];
  }

  void _loadDummyDrivers() {
    driverLocations.value = [
      const LatLng(-7.4252, 109.2313),
      const LatLng(-7.4232, 109.2293),
      const LatLng(-7.4262, 109.2323),
    ];
  }

  // --- MAP CONTROL ---

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (userLocation.value != null) {
      animateCameraToPosition(userLocation.value!);
    }
  }

  Future<void> animateCameraToPosition(LatLng position) async {
    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  Future<void> animateCameraToBounds(LatLng pickup, LatLng destination) async {
    final bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < destination.latitude
            ? pickup.latitude
            : destination.latitude,
        pickup.longitude < destination.longitude
            ? pickup.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > destination.latitude
            ? pickup.latitude
            : destination.latitude,
        pickup.longitude > destination.longitude
            ? pickup.longitude
            : destination.longitude,
      ),
    );

    await mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  // --- SEARCH & PLACES ---

  void onPickupQueryChanged(String query) {
    pickupQuery.value = query;
    isSearchingPickup.value = true;
    isSearchingDestination.value = false;
    predictions.clear();
    _searchPlacesDebounced(query);
  }

  void onDestinationQueryChanged(String query) {
    destinationQuery.value = query;
    isSearchingDestination.value = true;
    isSearchingPickup.value = false;
    predictions.clear();
    _searchPlacesDebounced(query);
  }

  void _searchPlacesDebounced(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length > 2) {
        _searchPlaces(query);
      } else {
        predictions.clear();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    try {
      final results = await _placesService.searchPlaces(query);
      predictions.value = results;
    } catch (e) {
      print('Error searching places: $e');
      predictions.clear();
    }
  }

  Future<void> onPredictionSelected(PlacePrediction prediction) async {
    try {
      final placeDetails = await _placesService.getPlaceDetails(
        prediction.placeId,
      );
      if (placeDetails == null) return;

      if (isSearchingPickup.value) {
        pickupLatLng = placeDetails.location;
        pickupQuery.value = placeDetails.name;
        pickupAddress.value = placeDetails.address;
        await animateCameraToPosition(placeDetails.location);
      } else {
        destLatLng = placeDetails.location;
        destinationQuery.value = placeDetails.name;
        destinationAddress.value = placeDetails.address;
      }

      predictions.clear();
      isSearchingPickup.value = false;
      isSearchingDestination.value = false;

      // If both locations set, move to pickup confirm
      if (pickupLatLng != null && destLatLng != null) {
        currentStage.value = OrderStage.pickupConfirm;
      }
    } catch (e) {
      print('Error selecting prediction: $e');
    }
  }

  Future<void> onSavedPlaceSelected(SavedPlace place) async {
    try {
      final placeDetails = await _placesService.getPlaceDetails(place.placeId);
      if (placeDetails == null) return;

      // Saved places always set as destination
      destLatLng = placeDetails.location;
      destinationQuery.value = placeDetails.name;
      destinationAddress.value = placeDetails.address;

      predictions.clear();
      isSearchingDestination.value = false;

      if (pickupLatLng != null) {
        currentStage.value = OrderStage.pickupConfirm;
      }
    } catch (e) {
      print('Error selecting saved place: $e');
    }
  }

  void onTextFieldFocus() {
    // Expand bottom sheet (handled in view)
  }

  void onLocationClick() {
    // Set current location as pickup
    if (userLocation.value != null) {
      pickupLatLng = userLocation.value;
      pickupQuery.value = 'Lokasi saat ini';
      pickupAddress.value = 'Menggunakan lokasi Anda saat ini';
      animateCameraToPosition(userLocation.value!);
    }
  }

  void clearQuery({required bool isPickup}) {
    if (isPickup) {
      pickupQuery.value = '';
      pickupLatLng = null;
      predictions.clear();
    } else {
      destinationQuery.value = '';
      destLatLng = null;
      predictions.clear();
    }
  }

  // --- ORDER FLOW ---

  // --- ORDER FLOW ---

  Future<void> onProceedClick() async {
    if (pickupLatLng == null || destLatLng == null) return;

    isRouteLoading.value = true;

    try {
      final routeDetails = await _rideService.getRouteDetails(
        origin: pickupLatLng!,
        destination: destLatLng!,
      );

      estimatedDistance.value = routeDetails.distanceKm;
      estimatedDuration.value = routeDetails.durationMins;

      PolylinePoints polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          destination: PointLatLng(destLatLng!.latitude, destLatLng!.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.status == 'OK' && result.points.isNotEmpty) {
        routePolylinePoints.value = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } else {
        print("Gagal fetch rute jalan: ${result.errorMessage}");
        routePolylinePoints.clear();
      }

      // Calculate price
      _recalculatePriceOnly();

      print(
        'Route calculated: Price=${estimatedPrice.value}, Distance=${estimatedDistance.value}, Duration=${estimatedDuration.value}',
      );

      // Animate camera to show route
      await animateCameraToBounds(pickupLatLng!, destLatLng!);

      // Move to route confirm AFTER data is ready
      currentStage.value = OrderStage.routeConfirm;
    } catch (e) {
      Get.snackbar("Error", "Gagal menghitung rute: $e");
      print(e);
    } finally {
      isRouteLoading.value = false;
    }
  }

  void _recalculatePriceOnly() {
    final selectedVehicle = vehicleTypes.firstWhere(
      (v) => v['type'] == selectedVehicleType.value,
      orElse: () => vehicleTypes[0],
    );

    final pricePerKm = selectedVehicle['pricePerKm'] as int;
    estimatedPrice.value = estimatedDistance.value * pricePerKm;
  }

  void selectVehicleType(String type) {
    selectedVehicleType.value = type;
    _recalculatePriceOnly();
  }

  void onBackClick() {
    if (currentStage.value == OrderStage.search) {
      // Go back to previous screen (passenger main)
      Get.back();
    } else if (currentStage.value == OrderStage.pickupConfirm) {
      currentStage.value = OrderStage.search;
      destLatLng = null;
      destinationQuery.value = '';
    } else if (currentStage.value == OrderStage.routeConfirm) {
      currentStage.value = OrderStage.pickupConfirm;
    }
  }

  Future<void> onCreateOrderClick() async {
    if (pickupLatLng == null || destLatLng == null) return;

    try {
      isLoading.value = true;

      final success = await _rideService.requestRide(
        pickupLocation: LocationData(
          latitude: pickupLatLng!.latitude,
          longitude: pickupLatLng!.longitude,
          address: pickupQuery.value,
        ),
        destinationLocation: LocationData(
          latitude: destLatLng!.latitude,
          longitude: destLatLng!.longitude,
          address: destinationQuery.value,
        ),
        rideType: selectedVehicleType.value == 'mobil'
            ? RideType.premium
            : RideType.standard,
        notes: notesController.text,
        estimatedFare: estimatedPrice.value,
        estimatedDistance: estimatedDistance.value,
        estimatedDuration: estimatedDuration.value.toDouble(),
        encodedPolyline: encodedPolyline,
      );

      if (success) {
        final rideId = _rideService.currentRide?.id;
        if (rideId != null) {
          activeRideRequestId.value = rideId;
          currentStage.value = OrderStage.findingDriver;
          _listenToRideStatus(rideId);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat pesanan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToRideStatus(String rideId) {
    _rideStatusSubscription?.cancel();

    // Listen to ride status changes
    _rideStatusSubscription = _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final status = data.first['status'];
            if (status == 'accepted') {
              // Navigate to trip screen
              Get.offNamed('/trip/$rideId');
            }
          }
        });
  }

  void onCancelClick() async {
    try {
      if (activeRideRequestId.value != null) {
        // Cancel ride in database
        await _supabase
            .from('ride_requests')
            .update({'status': 'cancelled'})
            .eq('id', activeRideRequestId.value!);
      }

      _rideStatusSubscription?.cancel();
      activeRideRequestId.value = null;
      currentStage.value = OrderStage.routeConfirm;
    } catch (e) {
      print('Error cancelling order: $e');
    }
  }

  // Helper untuk get route info
  Map<String, String>? get routeInfo {
    if (estimatedPrice.value == 0) return null;

    return {
      'price': 'Rp ${estimatedPrice.value.toStringAsFixed(0)}',
      'distance': '${estimatedDistance.value.toStringAsFixed(1)} km',
      'duration': '${estimatedDuration.value} menit',
    };
  }
}
