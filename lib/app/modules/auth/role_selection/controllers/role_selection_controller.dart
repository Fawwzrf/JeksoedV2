import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

class RoleSelectionController extends GetxController {
  final selectedRole = Rx<String?>(null);

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void selectPassengerRole() {
    selectedRole.value = 'passenger';
    // Arahkan langsung ke register passenger
    Get.toNamed('/register-passenger');
  }

  void selectDriverRole() {
    selectedRole.value = 'driver';
    // Arahkan ke register driver step 1
    Get.toNamed(Routes.registerDriverStep1);
  }

  void proceedToRegister() {
    if (selectedRole.value == null) {
      Get.snackbar(
        'Error',
        'Silakan pilih role terlebih dahulu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRole.value == 'passenger') {
      Get.toNamed('/register-passenger');
    } else if (selectedRole.value == 'driver') {
      Get.toNamed('/register-driver');
    }
  }

  void goBack() {
    Get.back();
  }
}
