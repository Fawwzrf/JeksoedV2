import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

class RegisterDriverController extends GetxController {
  // Step 1: Identitas
  final nameController = TextEditingController();
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Step 2: Dokumen
  final driverLicenseController = TextEditingController();
  final vehiclePlateController = TextEditingController();
  
  // Step 3: Verifikasi
  final agreementAccepted = false.obs;

  // State management
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void submitStep1() {
    if (nameController.text.isEmpty ||
        nimController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar("Error", "Semua field harus diisi!");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Password tidak cocok!");
      return;
    }

    nextStep();
  }

  void submitStep2() {
    if (driverLicenseController.text.isEmpty ||
        vehiclePlateController.text.isEmpty) {
      Get.snackbar("Error", "Nomor SIM dan plat kendaraan harus diisi!");
      return;
    }

    nextStep();
  }

  void submitStep3() async {
    if (!agreementAccepted.value) {
      Get.snackbar("Error", "Anda harus menyetujui syarat dan ketentuan!");
      return;
    }

    try {
      isLoading.value = true;
      
      // Simulasi proses registrasi
      await Future.delayed(Duration(milliseconds: 2000));
      
      Get.snackbar("Success", "Registrasi driver berhasil! Menunggu verifikasi admin.");
      Get.offAllNamed(Routes.driverMain);
      
    } catch (e) {
      Get.snackbar("Error", "Registrasi gagal: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.offNamed(Routes.login);
  }

  @override
  void onClose() {
    nameController.dispose();
    nimController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    driverLicenseController.dispose();
    vehiclePlateController.dispose();
    super.onClose();
  }
}
