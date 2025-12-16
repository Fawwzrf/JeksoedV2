// filepath: lib/app/modules/driver/main/views/driver_main_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/driver_main_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../home/views/driver_home_view.dart';
import '../../../shared/activity/views/activity_view.dart';
import '../../../shared/profile/views/profile_view.dart';

class DriverMainView extends GetView<DriverMainController> {
  const DriverMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DriverHomeView(),
      const ActivityViewWithTabs(),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: _CustomDriverNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
      ),
    );
  }
}

// Custom Bottom Navigation mirip Passenger
class _CustomDriverNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  _CustomDriverNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavBarItemData('Home', 'assets/images/home_icon.svg'),
    _NavBarItemData('Activity', 'assets/images/maps_icon.svg'),
    _NavBarItemData('Profil', 'assets/images/profil_icon.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9D9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          return Expanded(
            child: Obx(() {
              final selected = i == Get.find<DriverMainController>().currentIndex.value;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      key: ValueKey('indicator-$i'),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      height: 4,
                      width: selected ? 40 : 0,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.ease,
                      switchOutCurve: Curves.ease,
                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                      child: _NavBarIcon(
                        key: ValueKey('icon-$i-$selected'),
                        assetPath: _items[i].iconAsset,
                        color: selected ? AppColors.primaryDark : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      key: ValueKey('label-$i'),
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected ? AppColors.primaryDark : Colors.black,
                      ),
                      child: Text(_items[i].label),
                    ),
                  ],
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class _NavBarItemData {
  final String label;
  final String iconAsset;
  const _NavBarItemData(this.label, this.iconAsset);
}

class _NavBarIcon extends StatelessWidget {
  final String assetPath;
  final Color color;
  const _NavBarIcon({Key? key, required this.assetPath, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.svg')) {
      return SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          assetPath,
          color: color,
        ),
      );
    } else {
      return Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: color,
      );
    }
  }
}
