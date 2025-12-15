import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/passenger_main_controller.dart';
import '../../../home_passenger/views/home_passenger_view.dart';
import '../../../shared/activity/views/activity_view.dart';
import '../../../shared/profile/views/profile_view.dart';
import '../../../../../utils/app_colors.dart';

class PassengerMainView extends GetView<PassengerMainController> {
  const PassengerMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePassengerView(),
      const ActivityViewWithTabs(),
      const ProfileView(),
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
            selectedItemColor: AppColors.primary,
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
