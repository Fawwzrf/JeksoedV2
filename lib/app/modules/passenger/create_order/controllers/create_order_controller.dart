import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../data/services/ride_service.dart';

// Model untuk hasil pencarian (PlaceResult)
class PlaceResult {
  final String title;
  final String subtitle;
  final LatLng latLng;
  PlaceResult({
    required this.title,
    required this.subtitle,
    required this.latLng,
  });
}

enum OrderStage { search, pickupConfirm, routeConfirm, findingDriver }

class CreateOrderController extends GetxController {
  static const String googleMapsApiKey = 'AIzaSyAuyoAFHTVJRA6WKBRGnDc1mQ1ZQk7pl2A';
  
  final RideService _rideService = Get.find<RideService>();

  // Controllers
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final notesController = TextEditingController();
  
  // Google Maps Controller
  GoogleMapController? mapController;
  final Rx<CameraPosition> cameraPosition = const CameraPosition(
    target: LatLng(-7.4242, 109.2303),
    zoom: 15,
  ).obs;

  // State
  final isLoading = false.obs;
  final isFormValid = false.obs;
  final currentStage = OrderStage.search.obs;
  final selectedVehicleType = 'motor'.obs;

  // Inisialisasi dengan 0 agar aman dari error null
  final estimatedPrice = 0.0.obs;
  final estimatedDistance = 0.0.obs;
  final estimatedDuration = 0.obs;
  String? encodedPolyline;

  final searchResults = <PlaceResult>[].obs;
  final isSearchingLocation = false.obs;
  Timer? _debounce;

  // Default coordinates (Purwokerto)
  LatLng? pickupLatLng = const LatLng(-7.4242, 109.2303);
  LatLng? destLatLng = const LatLng(-7.4000, 109.2500);

  // PERBAIKAN 1: Menambahkan 'pricePerKm' agar View tidak error saat membacanya
  final vehicleTypes = [
    {
      'type': 'motor',
      'name': 'JekMotor',
      'icon': Icons.motorcycle,
      'description': 'Cepat dan hemat untuk sendiri',
      'pricePerKm': 2500,
    },
    {
      'type': 'mobil',
      'name': 'JekMobil',
      'icon': Icons.directions_car,
      'description': 'Nyaman untuk beramai-ramai',
      'pricePerKm': 4000,
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
      
      // Update camera position
      cameraPosition.value = CameraPosition(
        target: userLocation.value!,
        zoom: 15,
      );
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
          .maybeSingle();
      
      if (response != null) {
        userPhotoUrl.value = response['photo_url'];
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _loadSavedPlaces() {
    // Dummy saved places (later fetch from Supabase)
    savedPlaces.value = [
      SavedPlace(
        title: 'RITA SuperMall Purwokerto',
        address: 'Jl. Jend. Sudirman No.296, Pereng, Sokanegara',
        distance: '3.6 Km',
        placeId: 'ChIJ82-b1T-9LS4R_L8TCAjZ1zE',
      ),
      SavedPlace(
        title: 'RSU Wiradadi Husada',
        address: 'Jl. Menteri Supeno No.25, Dusun I Wiradadi',
        distance: '3.6 Km',
        placeId: 'ChIJb6t8jAGALS4RmR-nwpE9Aaw',
      ),
    ];
  }

  void _loadDummyDrivers() {
    // Dummy driver locations
    driverLocations.value = [
      const LatLng(-7.430, 109.246),
      const LatLng(-7.432, 109.244),
      const LatLng(-7.425, 109.240),
    ];
  }

  // --- GOOGLE MAPS ---

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> animateCameraToPosition(LatLng target, {double zoom = 15}) async {
    await mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  Future<void> animateCameraToBounds(LatLng pickup, LatLng destination) async {
    final bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < destination.latitude ? pickup.latitude : destination.latitude,
        pickup.longitude < destination.longitude ? pickup.longitude : destination.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > destination.latitude ? pickup.latitude : destination.latitude,
        pickup.longitude > destination.longitude ? pickup.longitude : destination.longitude,
      ),
    );
    
    await mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  // --- LOCATION SEARCH ---

  void onSearchTextChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length > 2) {
        _searchPlaces(query);
      } else {
        searchResults.clear();
      }
    });
  }

  Future<void> _searchPlacesApi(String query) async {
    try {
      isSearchingLocation.value = true;
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        List<PlaceResult> results = [];
        for (var loc in locations.take(5)) {
          try {
            List<Placemark> p = await placemarkFromCoordinates(
              loc.latitude,
              loc.longitude,
            );
            if (p.isNotEmpty) {
              final place = p.first;
              final title = place.street ?? place.name ?? query;
              final subtitle = [
                place.subLocality,
                place.locality,
              ].where((e) => e != null && e.isNotEmpty).join(", ");

              results.add(
                PlaceResult(
                  title: title,
                  subtitle: subtitle,
                  latLng: LatLng(loc.latitude, loc.longitude),
                ),
              );
            }
          } catch (_) {}
        }
        searchResults.value = results;
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isSearchingLocation.value = false;
    }
  }

  // PERBAIKAN 2: Menambahkan method yang dipanggil oleh View (_buildLocationInput & List)
  void selectLocationFromSuggestion(PlaceResult place, bool isPickup) {
    if (isPickup) {
      pickupController.text = place.title;
      pickupLatLng = place.latLng;
    } else {
      destinationController.text = place.title;
      destLatLng = place.latLng;
    }
    searchResults.clear();
    Get.back(); // Menutup bottom sheet
  }

  // PERBAIKAN 3: Menambahkan method untuk Quick Suggestion
  Future<void> searchLocationFromText(String query, bool isPickup) async {
    try {
      isLoading.value = true;
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);

        if (isPickup) {
          pickupController.text = query;
          pickupLatLng = latLng;
        } else {
          destinationController.text = query;
          destLatLng = latLng;
        }

        if (Get.isBottomSheetOpen ?? false) Get.back();
      }
    } catch (e) {
      Get.snackbar("Error", "Lokasi tidak ditemukan");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper untuk setter manual (dipakai di view _selectLocation)
  void setPickupLocation(String address, LatLng latLng) {
    pickupController.text = address;
    pickupLatLng = latLng;
  }

  void setDestinationLocation(String address, LatLng latLng) {
    destinationController.text = address;
    destLatLng = latLng;
  }

  // --- ORDER LOGIC ---

  void selectVehicleType(String type) {
    selectedVehicleType.value = type;
    _recalculatePriceOnly();
  }

  Future<void> calculateRouteAndPrice() async {
    if (pickupLatLng == null || destLatLng == null) return;
    
    isRouteLoading.value = true;
    
    try {
      // Get route details
      final routeDetails = await _rideService.getRouteDetails(
        origin: pickupLatLng!,
        destination: destLatLng!,
      );

      estimatedDistance.value = routeDetails.distanceKm;
      estimatedDuration.value = routeDetails.durationMins;
      encodedPolyline = routeDetails.encodedPolyline;

      // Calculate price
      _recalculatePriceOnly();
      
      print('Route calculated: Price=${estimatedPrice.value}, Distance=${estimatedDistance.value}, Duration=${estimatedDuration.value}');

      // Animate camera to show route
      await animateCameraToBounds(pickupLatLng!, destLatLng!);
      
      // Move to route confirm AFTER data is ready
      currentStage.value = OrderStage.routeConfirm;
    } catch (e) {
      Get.snackbar("Error", "Gagal menghitung rute: $e");
    } finally {
      isRouteLoading.value = false;
    }
  }

  void _recalculatePriceOnly() {
    RideType type = selectedVehicleType.value == 'mobil'
        ? RideType.premium
        : RideType.standard;

    estimatedPrice.value = _rideService.calculateFare(
      distanceKm: estimatedDistance.value,
      rideType: type,
    );
  }

  void nextStage() async {
    switch (currentStage.value) {
      case OrderStage.search:
        if (isFormValid.value) {
          currentStage.value = OrderStage.pickupConfirm;
        }
        break;
      case OrderStage.pickupConfirm:
        await calculateRouteAndPrice();
        currentStage.value = OrderStage.routeConfirm;
        break;
      case OrderStage.routeConfirm:
        createRideRequest();
        break;
      case OrderStage.findingDriver:
        Get.offAllNamed('/passenger-main');
        break;
    }
  }

  void previousStage() {
    switch (currentStage.value) {
      case OrderStage.pickupConfirm:
        currentStage.value = OrderStage.search;
        break;
      case OrderStage.routeConfirm:
        currentStage.value = OrderStage.pickupConfirm;
        break;
      case OrderStage.findingDriver:
        currentStage.value = OrderStage.routeConfirm;
        break;
      case OrderStage.search:
        Get.back();
        break;
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

  void cancelSearch() => Get.back();

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
