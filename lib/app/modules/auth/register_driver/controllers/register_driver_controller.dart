import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_pages.dart';
import '../../../../data/services/auth_service.dart';

class RegisterDriverController extends GetxController {
  //  Identitas
  final nameController = TextEditingController();
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Profile Image Handling
  final RxString profileImagePath = ''.obs;
  final RxString simPath = ''.obs;
  final RxString stnkPath = ''.obs;
  final RxString vehiclePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  // Dokumen
  final driverLicenseController = TextEditingController();
  final vehiclePlateController = TextEditingController();

  //  Verifikasi
  final agreementAccepted = false.obs;

  // State management
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil gambar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickDocumentImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        switch (type) {
          case 'sim':
            simPath.value = image.path;
            break;
          case 'stnk': // atau ktp
            stnkPath.value = image.path;
            break;
          case 'vehicle':
            vehiclePath.value = image.path;
            break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil dokumen: $e');
    }
  }

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

      final userData = {
        'name': nameController.text,
        'nim': nimController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
      };

      // Persiapkan Data Driver
      final driverData = {
        'licenseNumber': driverLicenseController.text,
        'vehiclePlate': vehiclePlateController.text,
        'vehicleType': 'motor',
        'ktp_path': null,
        'sim_path': null,
        'vehicle_path': null,
      };

      // Panggil AuthService
      final success = await AuthService.to.registerDriver(userData, driverData);

      if (success) {
        // Redirect ke login atau halaman menunggu verifikasi
        Get.offAllNamed(Routes.login);
      }
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
