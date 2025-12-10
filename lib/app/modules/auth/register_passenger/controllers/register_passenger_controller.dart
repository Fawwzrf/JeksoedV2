import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_pages.dart';

class RegisterPassengerController extends GetxController {
  final nameC = TextEditingController();
  final nimC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passwordC = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void register() async {
    if (nameC.text.isEmpty ||
        nimC.text.isEmpty ||
        emailC.text.isEmpty ||
        phoneC.text.isEmpty ||
        passwordC.text.isEmpty) {
      Get.snackbar("Error", "Semua field harus diisi!");
      return;
    }
    try {
      isLoading.value = true;

      final success = await AuthService.to.registerPassenger(
        name: nameC.text,
        nim: nimC.text,
        email: emailC.text,
        phone: phoneC.text,
        password: passwordC.text,
      );

      if (success) {
        Get.snackbar(
          "Success",
          "Registrasi berhasil! Selamat datang ${nameC.text}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.passengerMain);
      }
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    nimC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}
