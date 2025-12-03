import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  // Current user
  final Rx<User?> _currentUser = Rx<User?>(null);
  User? get currentUser => _currentUser.value;

  // Authentication state
  final RxBool _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check if user is already logged in
  void _checkAuthStatus() {
    // TODO: Check if user token exists in local storage
    // TODO: Validate token with backend
    // For now, set to false
    _isLoggedIn.value = false;
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual login logic with Firebase/API
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Mock user data
      final userData = {
        'id': '123',
        'name': 'Test User',
        'email': email,
        'phone': '+1234567890',
        'user_type': 'passenger',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _currentUser.value = User.fromJson(userData);
      _isLoggedIn.value = true;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register new user
  Future<bool> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual registration logic with Firebase/API
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Mock user data
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'phone': phone,
        'user_type': 'passenger',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _currentUser.value = User.fromJson(userData);
      _isLoggedIn.value = true;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register new driver with comprehensive data
  Future<bool> registerDriver(
    Map<String, dynamic> userData,
    Map<String, dynamic> driverData,
  ) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual driver registration logic with Firebase/API
      // This would include:
      // 1. Create user account
      // 2. Upload documents and images
      // 3. Create driver profile
      // 4. Set status to pending review

      await Future.delayed(const Duration(seconds: 3)); // Simulate API call

      // Mock success response
      Get.snackbar(
        'Application Submitted',
        'Your driver application has been submitted for review. You will be notified once approved.',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        'Driver registration failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register new driver (legacy method for compatibility)
  Future<bool> registerDriverLegacy({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String vehicleType,
    required String vehiclePlate,
  }) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual driver registration logic with Firebase/API
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      // Mock user data
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'phone': phone,
        'user_type': 'driver',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _currentUser.value = User.fromJson(userData);
      _isLoggedIn.value = true;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Driver registration failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // TODO: Clear token from local storage
      // TODO: Call logout API if needed

      _currentUser.value = null;
      _isLoggedIn.value = false;

      // Navigate to splash screen
      Get.offAllNamed('/splash');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading.value = true;

      if (_currentUser.value == null) return false;

      // TODO: Implement actual update profile logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      _currentUser.value = _currentUser.value!.copyWith(
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual change password logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Password change failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual reset password logic with Firebase/API
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      Get.snackbar(
        'Success',
        'Password reset email sent to $email',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
