import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  // Get AuthService instance
  final AuthService _authService = AuthService.to;

  void sendResetEmail() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan masukkan email Anda',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Gunakan AuthService dengan Supabase
      final success = await _authService.resetPassword(
        emailController.text.trim(),
      );

      if (success) {
        Get.snackbar(
          'Berhasil',
          'Email reset password telah dikirim. Silakan periksa inbox Anda',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );

        // Navigate back to login
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
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
    emailController.dispose();
    super.onClose();
  }
}
