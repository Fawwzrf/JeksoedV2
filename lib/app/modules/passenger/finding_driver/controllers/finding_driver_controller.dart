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
  }
  
  @override
  void onClose() {
    _stopAllTimers();
    super.onClose();
  }
  
  void _initializeSearch() {
    _startSearchAnimation();
    _startDurationCounter();
    _simulateDriverSearch();
  }
  
  void _startSearchAnimation() {
    _rotationTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        rotationValue.value = (rotationValue.value + 0.1) % (2 * 3.14159);
      },
    );
  }
  
  void _startDurationCounter() {
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        searchDuration.value++;
        
        // Update status messages based on duration
        if (searchDuration.value <= 15) {
          searchStatus.value = 'Looking for nearby drivers...';
        } else if (searchDuration.value <= 30) {
          searchStatus.value = 'Expanding search radius...';
        } else {
          searchStatus.value = 'Connecting with available drivers...';
        }
      },
    );
  }
  
  void _simulateDriverSearch() {
    // Simulate finding a driver after 45 seconds
    _searchTimer = Timer(
      const Duration(seconds: 45),
      () {
        _foundDriver();
      },
    );
  }
  
  void _foundDriver() {
    isSearching.value = false;
    estimatedArrival.value = '5 minutes';
    
    _stopAllTimers();
    
    Get.snackbar(
      'Driver Found!',
      'Your driver is on the way',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  void _stopAllTimers() {
    _searchTimer?.cancel();
    _durationTimer?.cancel();
    _stopRotationAnimation();
  }
  
  void _stopRotationAnimation() {
    _rotationTimer?.cancel();
  }
  
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  // Public methods for UI interaction
  void cancelSearch() {
    _stopAllTimers();
    
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
