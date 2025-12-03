import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum OrderStage { search, pickupConfirm, routeConfirm, findingDriver }

class CreateOrderController extends GetxController {
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final notesController = TextEditingController();

  final isLoading = false.obs;
  final currentStage = OrderStage.search.obs;
  final selectedVehicleType = ''.obs;
  final estimatedPrice = 0.0.obs;
  final estimatedDistance = 0.0.obs;
  final estimatedDuration = 0.obs;

  // Mock driver data for finding driver stage
  final driverFound = false.obs;
  final driverName = ''.obs;
  final driverRating = 0.0.obs;
  final driverPlate = ''.obs;
  final driverArrivalTime = 0.obs;

  final vehicleTypes = [
    {
      'type': 'motor',
      'name': 'JekMotor',
      'icon': Icons.motorcycle,
      'pricePerKm': 2000,
      'description': 'Cepat dan praktis untuk perjalanan solo',
    },
    {
      'type': 'mobil',
      'name': 'JekMobil',
      'icon': Icons.directions_car,
      'pricePerKm': 3500,
      'description': 'Nyaman untuk perjalanan berlima',
    },
  ];
  @override
  void onInit() {
    super.onInit();
    // Set default vehicle type
    if (vehicleTypes.isNotEmpty) {
      selectedVehicleType.value = vehicleTypes[0]['type'] as String;
    }
  }

  // Stage navigation methods
  void nextStage() {
    switch (currentStage.value) {
      case OrderStage.search:
        if (pickupController.text.isNotEmpty &&
            destinationController.text.isNotEmpty) {
          currentStage.value = OrderStage.pickupConfirm;
        }
        break;
      case OrderStage.pickupConfirm:
        currentStage.value = OrderStage.routeConfirm;
        calculatePrice();
        break;
      case OrderStage.routeConfirm:
        currentStage.value = OrderStage.findingDriver;
        findDriver();
        break;
      case OrderStage.findingDriver:
        // Navigate to trip screen or back to home
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

  void findDriver() async {
    driverFound.value = false;

    // Simulate driver search
    await Future.delayed(const Duration(seconds: 3));

    // Mock driver data
    driverFound.value = true;
    driverName.value = 'Ahmad Sudirman';
    driverRating.value = 4.8;
    driverPlate.value = 'R 1234 ABC';
    driverArrivalTime.value = 5;
  }

  void cancelSearch() {
    Get.back();
  }

  void selectVehicleType(String type) {
    selectedVehicleType.value = type;
    calculatePrice();
  }

  void calculatePrice() {
    // Mock calculation - in real app this would use Google Maps API
    if (pickupController.text.isNotEmpty &&
        destinationController.text.isNotEmpty) {
      // Simulate distance calculation
      estimatedDistance.value = 5.0; // km
      estimatedDuration.value = 15; // minutes

      final selectedType = vehicleTypes.firstWhere(
        (type) => type['type'] == selectedVehicleType.value,
        orElse: () => vehicleTypes[0],
      );

      final pricePerKm = selectedType['pricePerKm'] as int;
      estimatedPrice.value =
          estimatedDistance.value * pricePerKm + 5000; // base fare
    }
  }

  void setPickupLocation(String location) {
    pickupController.text = location;
    calculatePrice();
  }

  void setDestinationLocation(String location) {
    destinationController.text = location;
    calculatePrice();
  }

  void createRideRequest() async {
    if (pickupController.text.isEmpty) {
      Get.snackbar('Error', 'Silakan pilih lokasi penjemputan');
      return;
    }

    if (destinationController.text.isEmpty) {
      Get.snackbar('Error', 'Silakan pilih lokasi tujuan');
      return;
    }

    if (selectedVehicleType.value.isEmpty) {
      Get.snackbar('Error', 'Silakan pilih jenis kendaraan');
      return;
    }

    try {
      isLoading.value = true;

      // TODO: Implement actual ride request creation
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Generate mock ride request ID
      final rideRequestId = 'ride_${DateTime.now().millisecondsSinceEpoch}';

      Get.snackbar(
        'Berhasil',
        'Permintaan perjalanan berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to finding driver screen
      Get.toNamed('/finding-driver/$rideRequestId');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuat permintaan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
