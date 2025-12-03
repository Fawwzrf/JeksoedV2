import 'package:get/get.dart';
import 'dart:async';
import '../../../../routes/app_pages.dart';

class CtaController extends GetxController {
  var currentPage = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startAutoPageChange();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startAutoPageChange() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      currentPage.value = (currentPage.value + 1) % 3; // 3 pages total
    });
  }

  void goToLogin() {
    Get.toNamed('/login');
  }

  void goToRoleSelection() {
    Get.toNamed('/role-selection');
  }

  void goToTerms() {
    Get.toNamed(Routes.tnc);
  }
}
