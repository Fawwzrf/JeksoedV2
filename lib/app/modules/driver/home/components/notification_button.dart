// filepath: lib/app/modules/driver/home/components/notification_button.dart

import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class NotificationButton extends StatelessWidget {
  final VoidCallback onNotificationClick;

  const NotificationButton({super.key, required this.onNotificationClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onNotificationClick,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                // Notification badge (optional - you can add a counter here)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
