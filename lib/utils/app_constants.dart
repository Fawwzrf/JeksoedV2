import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'JeksoedV2';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Ride sharing app built with Flutter';

  // API Endpoints (when needed)
  static const String baseUrl = 'https://your-api-endpoint.com/api/v1';
  static const String authEndpoint = '$baseUrl/auth';
  static const String ridesEndpoint = '$baseUrl/rides';
  static const String usersEndpoint = '$baseUrl/users';

  // Shared Preferences Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  static const String themeKey = 'app_theme';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Map Related
  static const double defaultMapZoom = 16.0;
  static const double closeMapZoom = 18.0;
  static const double farMapZoom = 12.0;

  // Ride Related
  static const double minimumRideDistance = 0.5; // km
  static const double maximumRideDistance = 50.0; // km
  static const int rideSearchRadius = 10; // km
  static const int maxDriverWaitTime = 300; // seconds (5 minutes)

  // UI Related
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputBorderRadius = 8.0;

  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);

  // Text Sizes
  static const double titleTextSize = 24.0;
  static const double subtitleTextSize = 18.0;
  static const double bodyTextSize = 16.0;
  static const double smallTextSize = 14.0;
  static const double tinyTextSize = 12.0;

  // Error Messages
  static const String networkError = 'Periksa koneksi internet Anda';
  static const String genericError = 'Terjadi kesalahan. Silakan coba lagi';
  static const String authError =
      'Sesi Anda telah berakhir. Silakan login kembali';
  static const String validationError = 'Harap isi semua field yang diperlukan';

  // Success Messages
  static const String loginSuccess = 'Login berhasil';
  static const String registerSuccess = 'Registrasi berhasil';
  static const String updateSuccess = 'Data berhasil diperbarui';
  static const String rideRequestSuccess =
      'Permintaan perjalanan berhasil dikirim';

  // User Roles
  static const String passengerRole = 'passenger';
  static const String driverRole = 'driver';
  static const String adminRole = 'admin';

  // Vehicle Types
  static const List<String> vehicleTypes = ['Mobil', 'Motor', 'Sepeda'];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Tunai',
    'Kartu Kredit',
    'Dompet Digital',
    'Transfer Bank',
  ];

  // Ride Status
  static const String rideRequested = 'requested';
  static const String rideAccepted = 'accepted';
  static const String rideInProgress = 'in_progress';
  static const String rideCompleted = 'completed';
  static const String rideCancelled = 'cancelled';

  // Notification Types
  static const String rideNotification = 'ride';
  static const String promotionNotification = 'promotion';
  static const String systemNotification = 'system';
  static const String paymentNotification = 'payment';
  // Helper methods
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // Validation methods
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    // Check if contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Nama hanya boleh mengandung huruf dan spasi';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    // Remove all non-digit characters for validation
    String phoneNumber = value.replaceAll(RegExp(r'\D'), '');

    // Check if starts with country code or local format
    if (phoneNumber.startsWith('62')) {
      // Indonesian number with country code
      if (phoneNumber.length < 10 || phoneNumber.length > 15) {
        return 'Nomor telepon tidak valid (10-15 digit)';
      }
    } else if (phoneNumber.startsWith('0')) {
      // Local Indonesian number
      if (phoneNumber.length < 10 || phoneNumber.length > 13) {
        return 'Nomor telepon tidak valid (10-13 digit)';
      }
    } else {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (value.length > 32) {
      return 'Password maksimal 32 karakter';
    }
    // Check if contains at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kapital';
    }
    // Check if contains at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kecil';
    }
    // Check if contains at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka';
    }
    return null;
  }

  // Date formatting method
  static String formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showWarningSnackbar(String message) {
    Get.snackbar(
      'Peringatan',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
