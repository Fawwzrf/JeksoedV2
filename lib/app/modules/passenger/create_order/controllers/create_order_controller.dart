import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/services/ride_service.dart';
import 'package:geocoding/geocoding.dart';

enum OrderStage { search, pickupConfirm, routeConfirm, findingDriver }

class CreateOrderController extends GetxController {
  final RideService _rideService = Get.find<RideService>();

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
  String? encodedPolyline; // Untuk menyimpan rute

  // Default coordinates (Purwokerto)
  LatLng? pickupLatLng = const LatLng(-7.4242, 109.2303);
  LatLng? destLatLng = const LatLng(-7.4000, 109.2500);

  final vehicleTypes = [
    {
      'type': 'motor',
      'name': 'JekMotor',
      'icon': Icons.motorcycle,
      'description': 'Cepat dan hemat untuk sendiri',
    },
    {
      'type': 'mobil',
      'name': 'JekMobil',
      'icon': Icons.directions_car,
      'description': 'Nyaman untuk beramai-ramai',
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

  // --- NAVIGATION ---
  void nextStage() async {
    switch (currentStage.value) {
      case OrderStage.search:
        if (pickupController.text.isNotEmpty &&
            destinationController.text.isNotEmpty) {
          currentStage.value = OrderStage.pickupConfirm;
        }
        break;

      case OrderStage.pickupConfirm:
        // Saat konfirmasi pickup, hitung rute & harga
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

  Future<void> searchLocationFromText(
    String addressQuery,
    bool isPickup,
  ) async {
    if (addressQuery.isEmpty) return;

    try {
      isLoading.value = true;

      List<Location> locations = await locationFromAddress(addressQuery);

      if (locations.isNotEmpty) {
        final Location location = locations.first;
        final LatLng newLatLng = LatLng(location.latitude, location.longitude);

        // Update state lokasi
        if (isPickup) {
          setPickupLocation(addressQuery, newLatLng);
          print("Pickup Updated: $addressQuery ($newLatLng)");
        } else {
          setDestinationLocation(addressQuery, newLatLng);
          print("Destination Updated: $addressQuery ($newLatLng)");
        }

        // Tutup bottom sheet/keyboard jika perlu
        if (Get.isBottomSheetOpen ?? false) Get.back();
      } else {
        Get.snackbar("Info", "Lokasi tidak ditemukan, coba nama lain.");
      }
    } catch (e) {
      print("Geocoding Error: $e");
      Get.snackbar(
        "Error",
        "Gagal mencari lokasi. Pastikan koneksi internet lancar.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIC ---

  void selectVehicleType(String type) {
    selectedVehicleType.value = type;
    // Recalculate price only (distance doesn't change)
    if (estimatedDistance.value > 0) {
      _recalculatePriceOnly();
    }
  }

  // Menggunakan RideService untuk menghitung rute
  Future<void> calculateRouteAndPrice() async {
    if (pickupLatLng == null || destLatLng == null) return;

    isLoading.value = true;
    try {
      // 1. Get Route Details (Simulasi API)
      final routeDetails = await _rideService.getRouteDetails(
        origin: pickupLatLng!,
        destination: destLatLng!,
      );

      estimatedDistance.value = routeDetails.distanceKm;
      estimatedDuration.value = routeDetails.durationMins;
      encodedPolyline = routeDetails.encodedPolyline;

      // 2. Calculate Price
      _recalculatePriceOnly();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghitung rute: $e");
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

  // Helper untuk View menetapkan lokasi (misal dari daftar favorit)
  void setPickupLocation(String address, LatLng latLng) {
    pickupController.text = address;
    pickupLatLng = latLng;
  }

  void setDestinationLocation(String address, LatLng latLng) {
    destinationController.text = address;
    destLatLng = latLng;
  }

  void createRideRequest() async {
    if (pickupLatLng == null || destLatLng == null) {
      Get.snackbar('Error', 'Lokasi tidak valid');
      return;
    }

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
      Get.snackbar('Error', 'Gagal membuat pesanan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void cancelSearch() => Get.back();

  @override
  void onClose() {
    pickupController.removeListener(_validateSearchForm);
    destinationController.removeListener(_validateSearchForm);
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
