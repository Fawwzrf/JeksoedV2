import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindingDriverController extends GetxController {
  // Observable variables
  final isSearching = true.obs;
  final searchDuration = 0.obs;
  final estimatedArrival = ''.obs;
  final searchStatus = 'Looking for nearby drivers...'.obs;

  Timer? _searchTimer;
  Timer? _durationTimer;

  // Animation controller for the searching indicator
  final rotationValue = 0.0.obs;
  Timer? _rotationTimer;

  // Mock data
  final pickupAddress = 'Jl. Mayjen Hryono 169, Surabaya'.obs;
  final destinationAddress = 'Universitas Negeri Surabaya'.obs;
  final estimatedPrice = 'Rp 15,000'.obs;
  final driverName = 'Budi Santoso'.obs;
  final driverRating = '4.8'.obs;
  final driverTrips = '1,250 trips'.obs;
  final vehicleInfo = 'Toyota Avanza - L 1234 AB'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSearch();
    _startRotationAnimation();
  }

  @override
  void onClose() {
    _stopSearch();
    _stopRotationAnimation();
    super.onClose();
  }

  void _initializeSearch() {
    // Get ride request ID from route parameters or arguments
    String? rideRequestId = Get.parameters['rideRequestId'];

    _startDriverSearch();
    _startDurationCounter();
  }

  void _startDriverSearch() {
    _searchTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateSearchStatus();

      // Simulate finding driver after 10-15 seconds
      if (searchDuration.value >= 10 && isSearching.value) {
        _simulateDriverFound();
      }
    });
  }

  void _updateSearchStatus() {
    final duration = searchDuration.value;

    if (duration < 5) {
      searchStatus.value = 'Looking for nearby drivers...';
    } else if (duration < 10) {
      searchStatus.value = 'Expanding search area...';
    } else if (duration < 15) {
      searchStatus.value = 'Almost there, finding the best driver...';
    } else {
      searchStatus.value = 'This is taking longer than usual...';
    }
  }

  void _simulateDriverFound() {
    isSearching.value = false;
    searchStatus.value = 'Driver found!';
    estimatedArrival.value = '3 minutes';

    _stopSearch();

    // Auto navigate to trip screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      // TODO: Navigate to trip screen
      Get.offAllNamed('/home-passenger');
    });
  }

  void _startDurationCounter() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      searchDuration.value++;
    });
  }

  void _startRotationAnimation() {
    _rotationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      rotationValue.value = (rotationValue.value + 0.02) % (2 * 3.14159);
    });
  }

  void _stopSearch() {
    _searchTimer?.cancel();
    _durationTimer?.cancel();
    _searchTimer = null;
    _durationTimer = null;
  }

  void _stopRotationAnimation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // User actions
  void cancelSearch() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text(
          'Are you sure you want to cancel this ride request?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () {
              _cancelRideRequest();
              Get.back();
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelRideRequest() {
    // TODO: Cancel ride request in the backend
    _stopSearch();
    _stopRotationAnimation();

    _showSuccess('Ride cancelled successfully');
    Get.back();
  }

  // Helper methods
  String get formattedDuration {
    final minutes = searchDuration.value ~/ 60;
    final seconds = searchDuration.value % 60;
    return '${minutes}m ${seconds}s';
  }
}
