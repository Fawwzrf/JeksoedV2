// filepath: lib/app/modules/driver/main/views/driver_main_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_main_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../home/views/driver_home_view.dart';
import '../../activity/views/driver_activity_view.dart';
import '../../profile/views/driver_profile_view.dart';

class DriverMainView extends GetView<DriverMainController> {
  const DriverMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DriverHomeView(),
      const DriverActivityView(),
      const DriverProfileView(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9D9), // Light yellow background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryGreen,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  controller.currentIndex.value == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  size: 24,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  controller.currentIndex.value == 1
                      ? Icons.history
                      : Icons.history_outlined,
                  size: 24,
                ),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  controller.currentIndex.value == 2
                      ? Icons.person
                      : Icons.person_outline,
                  size: 24,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
