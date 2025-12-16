import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/services/ride_service.dart';
// Pastikan Anda punya API Key di sini atau ganti string langsung di bawah
import '../../../../../utils/app_constants.dart';

// Model khusus untuk hasil Places API
class PlaceResult {
  final String placeId; // ID unik dari Google
  final String title; // Main text (misal: "Rita Supermall")
  final String subtitle; // Secondary text (misal: "Jalan Jend. Soedirman...")
  final LatLng? latLng; // Bisa null jika belum di-fetch detailnya

  PlaceResult({
    this.placeId = '',
    required this.title,
    required this.subtitle,
    this.latLng,
  });
}

enum OrderStage { search, pickupConfirm, routeConfirm, findingDriver }

class CreateOrderController extends GetxController {
  final RideService _rideService = Get.find<RideService>();

  // Gunakan GetConnect untuk HTTP Request ke Google API
  final _connect = GetConnect();

  final String _apiKey = "AIzaSyAuyoAFHTVJRA6WKBRGnDc1mQ1ZQk7pl2A";

  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final notesController = TextEditingController();

  final isLoading = false.obs;
  final isFormValid = false.obs;
  final currentStage = OrderStage.search.obs;
  final selectedVehicleType = 'motor'.obs;

  final estimatedPrice = 0.0.obs;
  final estimatedDistance = 0.0.obs;
  final estimatedDuration = 0.obs;
  String? encodedPolyline;

  // Menggunakan PlaceResult agar cocok dengan View
  final searchResults = <PlaceResult>[].obs;
  final isSearchingLocation = false.obs;
  Timer? _debounce;

  // Maps Controller
  final Completer<GoogleMapController> _mapController = Completer();
  final markers = <Marker>{}.obs;

  // Default coordinates (Purwokerto)
  LatLng? pickupLatLng = const LatLng(-7.4242, 109.2303);
  LatLng? destLatLng = const LatLng(-7.4000, 109.2500);

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
    if (vehicleTypes.isNotEmpty) {
      selectedVehicleType.value = vehicleTypes[0]['type'] as String;
    }
    pickupController.addListener(_validateSearchForm);
    destinationController.addListener(_validateSearchForm);
  }

  void _validateSearchForm() {
    isFormValid.value =
        pickupController.text.isNotEmpty &&
        destinationController.text.isNotEmpty;
  }

  // --- MAPS LOGIC ---
  void onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
    updateMapDisplay();
  }

  void updateMapDisplay() {
    markers.clear();
    if (pickupLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
    if (destLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Auto zoom fit
    if (pickupLatLng != null && destLatLng != null) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        final c = await _mapController.future;
        c.animateCamera(
          CameraUpdate.newLatLngBounds(
            _boundsFromLatLngList([pickupLatLng!, destLatLng!]),
            50,
          ),
        );
      });
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  // --- GOOGLE PLACES API LOGIC ---

  void onSearchTextChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.length < 3) {
      searchResults.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 700), () {
      _searchPlacesApi(query);
    });
  }

  Future<void> _searchPlacesApi(String query) async {
    try {
      isSearchingLocation.value = true;

      // 1. Panggil API Autocomplete
      // Session Token disarankan untuk billing, di sini kita skip dulu untuk simplifikasi
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=$query&'
          'key=$_apiKey&'
          'components=country:id'; // Batasi pencarian di Indonesia

      final response = await _connect.get(url);

      if (response.status.hasError) {
        print("Places API Error: ${response.statusText}");
        return;
      }

      final data = response.body;
      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;

        searchResults.value = predictions.map((p) {
          final structured = p['structured_formatting'] ?? {};
          return PlaceResult(
            placeId: p['place_id'],
            title: structured['main_text'] ?? p['description'],
            subtitle: structured['secondary_text'] ?? '',
          );
        }).toList();
      } else {
        searchResults.clear();
        print(
          "Places API Status: ${data['status']} - ${data['error_message']}",
        );
      }
    } catch (e) {
      print("Error fetching places: $e");
    } finally {
      isSearchingLocation.value = false;
    }
  }

  // Dipanggil saat user memilih salah satu item dari list
  Future<void> selectLocation(PlaceResult place, bool isPickup) async {
    // Jika LatLng sudah ada (misal dari History), langsung pakai
    LatLng selectedLatLng;

    if (place.latLng != null) {
      selectedLatLng = place.latLng!;
    } else {
      // Jika belum ada (dari API Autocomplete), kita harus fetch Detailnya
      selectedLatLng = await _getPlaceDetails(place.placeId);
    }

    // Update UI Controller
    if (isPickup) {
      pickupController.text = place.title;
      pickupLatLng = selectedLatLng;
    } else {
      destinationController.text = place.title;
      destLatLng = selectedLatLng;
    }

    searchResults.clear();
    Get.back(); // Tutup bottom sheet
  }

  // Fetch koordinat detail dari Place ID
  Future<LatLng> _getPlaceDetails(String placeId) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=$placeId&'
          'fields=geometry&' // Kita hanya butuh koordinat
          'key=$_apiKey';

      final response = await _connect.get(url);
      final data = response.body;

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    } catch (e) {
      print("Error details: $e");
    }
    // Fallback default jika gagal
    return const LatLng(-7.4242, 109.2303);
  }

  // --- ORDER LOGIC ---

  void selectVehicleType(String type) {
    selectedVehicleType.value = type;
    _recalculatePriceOnly();
  }

  Future<void> calculateRouteAndPrice() async {
    if (pickupLatLng == null || destLatLng == null) return;

    isLoading.value = true;
    try {
      final routeDetails = await _rideService.getRouteDetails(
        origin: pickupLatLng!,
        destination: destLatLng!,
      );

      estimatedDistance.value = routeDetails.distanceKm;
      estimatedDuration.value = routeDetails.durationMins;
      encodedPolyline = routeDetails.encodedPolyline;

      _recalculatePriceOnly();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghitung rute");
    } finally {
      isLoading.value = false;
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
          updateMapDisplay(); // Update map saat pindah stage
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
        updateMapDisplay();
        break;
      case OrderStage.findingDriver:
        currentStage.value = OrderStage.routeConfirm;
        break;
      case OrderStage.search:
        Get.back();
        break;
    }
  }

  void createRideRequest() async {
    if (pickupLatLng == null || destLatLng == null) return;

    try {
      isLoading.value = true;
      final success = await _rideService.requestRide(
        pickupLocation: LocationData(
          latitude: pickupLatLng!.latitude,
          longitude: pickupLatLng!.longitude,
          address: pickupController.text,
        ),
        destinationLocation: LocationData(
          latitude: destLatLng!.latitude,
          longitude: destLatLng!.longitude,
          address: destinationController.text,
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
          Get.offNamed('/finding-driver/$rideId');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal pesan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void cancelSearch() => Get.back();

  // Helper untuk View (misal untuk quick history)
  void setPickupLocation(String address, LatLng latLng) {
    pickupController.text = address;
    pickupLatLng = latLng;
  }

  void setDestinationLocation(String address, LatLng latLng) {
    destinationController.text = address;
    destLatLng = latLng;
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
