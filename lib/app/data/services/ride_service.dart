import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ride_request.dart';

class RideService extends GetxService {
  static RideService get to => Get.find();

  // Current ride request
  final Rx<RideRequest?> _currentRide = Rx<RideRequest?>(null);
  RideRequest? get currentRide => _currentRide.value;

  // Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  // Available rides for drivers
  final RxList<RideRequest> _availableRides = <RideRequest>[].obs;
  List<RideRequest> get availableRides => _availableRides;

  // Ride history
  final RxList<RideRequest> _rideHistory = <RideRequest>[].obs;
  List<RideRequest> get rideHistory => _rideHistory;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  void _initializeService() {
    // TODO: Initialize real-time listeners for rides
    // TODO: Load ride history
  }

  // Request a ride (for passengers)
  Future<bool> requestRide({
    required LocationData pickupLocation,
    required LocationData destinationLocation,
    required RideType rideType,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? notes,
  }) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual ride request logic with Firebase/API
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Create mock ride request
      final rideRequest = RideRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        passengerId: 'current_user_id', // TODO: Get from AuthService
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        status: RideStatus.requested,
        rideType: rideType,
        estimatedDistance: 5.2, // Mock data
        estimatedDuration: 15.0, // Mock data
        estimatedFare: 25000.0, // Mock data
        requestTime: DateTime.now(),
        paymentMethod: paymentMethod,
        notes: notes,
      );

      _currentRide.value = rideRequest;

      // TODO: Start looking for available drivers
      _findAvailableDrivers();

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to request ride: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Accept a ride (for drivers)
  Future<bool> acceptRide(String rideId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual ride acceptance logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      // Find the ride in available rides
      final rideIndex = _availableRides.indexWhere((ride) => ride.id == rideId);
      if (rideIndex == -1) return false;

      final ride = _availableRides[rideIndex].copyWith(
        status: RideStatus.accepted,
        driverId: 'current_driver_id', // TODO: Get from AuthService
        acceptedTime: DateTime.now(),
      );

      _currentRide.value = ride;
      _availableRides.removeAt(rideIndex);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept ride: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update ride status
  Future<bool> updateRideStatus(String rideId, RideStatus newStatus) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual status update logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      if (_currentRide.value?.id == rideId) {
        _currentRide.value = _currentRide.value!.copyWith(
          status: newStatus,
          startTime: newStatus == RideStatus.inProgress
              ? DateTime.now()
              : _currentRide.value!.startTime,
          completedTime: newStatus == RideStatus.completed
              ? DateTime.now()
              : _currentRide.value!.completedTime,
        );

        // If ride is completed, move to history
        if (newStatus == RideStatus.completed ||
            newStatus == RideStatus.cancelled) {
          _rideHistory.insert(0, _currentRide.value!);
          _currentRide.value = null;
        }
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update ride status: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Cancel ride
  Future<bool> cancelRide(String rideId, {String? reason}) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual ride cancellation logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      if (_currentRide.value?.id == rideId) {
        _currentRide.value = _currentRide.value!.copyWith(
          status: RideStatus.cancelled,
          notes: reason,
        );

        // Move to history
        _rideHistory.insert(0, _currentRide.value!);
        _currentRide.value = null;
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel ride: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Rate ride
  Future<bool> rateRide(String rideId, int rating, {String? comment}) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual rating logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      final rideRating = RideRating(
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      // Update ride in history
      final rideIndex = _rideHistory.indexWhere((ride) => ride.id == rideId);
      if (rideIndex != -1) {
        _rideHistory[rideIndex] = _rideHistory[rideIndex].copyWith(
          rating: rideRating,
        );
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to rate ride: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Load ride history
  Future<void> loadRideHistory() async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual history loading logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      // Mock data
      _rideHistory.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ride history: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Find available drivers (internal method)
  void _findAvailableDrivers() {
    // TODO: Implement real-time driver searching
    // This would typically involve location-based queries

    // Simulate finding drivers
    Timer(Duration(seconds: 5), () {
      if (_currentRide.value?.status == RideStatus.requested) {
        // Simulate no drivers found
        Get.snackbar(
          'Sorry',
          'No drivers available at the moment. Please try again.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        _currentRide.value = null;
      }
    });
  }

  // Load available rides for drivers
  Future<void> loadAvailableRides() async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual available rides loading logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      // Mock data
      _availableRides.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load available rides: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Calculate estimated fare
  double calculateEstimatedFare({
    required double distance,
    required RideType rideType,
  }) {
    // Basic fare calculation
    double baseFare = 5000.0; // Rp 5,000 base fare
    double perKmRate = 2000.0; // Rp 2,000 per km

    // Adjust rate based on ride type
    switch (rideType) {
      case RideType.premium:
        perKmRate *= 1.5;
        break;
      case RideType.shared:
        perKmRate *= 0.8;
        break;
      default:
        break;
    }

    return baseFare + (distance * perKmRate);
  }
}
