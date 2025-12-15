import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../../routes/app_pages.dart';

class CtaController extends GetxController {
  var currentPage = 0.obs;
  Timer? _timer;
  PageController pageController = PageController(initialPage: 0);  @override
  void onInit() {
    super.onInit();
    print('CtaController onInit called');
  }

  @override
  void onReady() {
    super.onReady();
    print('CtaController onReady called - PageController has clients: ${pageController.hasClients}');
    // Mulai auto scroll setelah widget ready
    _startAutoPageChange();
  }

  @override
  void onClose() {
    print('CtaController onClose called');
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _startAutoPageChange() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      print('Timer tick - current page: ${currentPage.value}');
      if (pageController.hasClients) {
        int nextPage = (currentPage.value + 1) % 3; // 3 pages total
        print('Animating to page: $nextPage');
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        print('PageController has no clients yet');
      }
    });
  }
  void onPageChanged(int index) {
    print('Page changed to: $index');
    currentPage.value = index;
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
