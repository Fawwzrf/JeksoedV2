import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class TopHeader extends StatelessWidget {
  final String name;
  final bool hasNotification;
  final VoidCallback onNotificationClick;

  const TopHeader({
    super.key,
    required this.name,
    required this.hasNotification,
    required this.onNotificationClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Halo, $name!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNotificationClick,
            icon: Icon(
              hasNotification
                  ? Icons.notifications
                  : Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
