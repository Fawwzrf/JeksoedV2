import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  // Get AuthService instance
  final AuthService _authService = AuthService.to;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar("Error", "Email dan password harus diisi!");
      return;
    }

    try {
      isLoading.value = true;

      // Login menggunakan Supabase via AuthService
      final success = await _authService.login(
        emailC.text.trim(),
        passwordC.text,
      );

      if (success) {
        // Cek user type dari currentUser
        final user = _authService.currentUser;

        if (user != null) {
          // Navigate berdasarkan user type
          if (user.userType.name == 'driver') {
            Get.offAllNamed(Routes.driverMain);
            Get.snackbar(
              "Success",
              "Login sebagai Driver berhasil!",
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            Get.offAllNamed(Routes.passengerMain);
            Get.snackbar(
              "Success",
              "Login sebagai Penumpang berhasil!",
              snackPosition: SnackPosition.BOTTOM,
            );
          }

          // Clear input fields
          emailC.clear();
          passwordC.clear();
        }
      } else {
        Get.snackbar(
          "Error",
          "Login gagal! Periksa email dan password Anda.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error during login: $e");
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.registerPassenger);
  }

  void goToRoleSelection() {
    Get.toNamed(Routes.roleSelection);
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.forgotPassword);
  }

  void goToTerms() {
    Get.toNamed(Routes.tnc);
  }

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}
