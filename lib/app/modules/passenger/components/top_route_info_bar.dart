import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class TopRouteInfoBar extends StatelessWidget {
  final String pickup;
  final String destination;

  const TopRouteInfoBar({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RouteInfoRow(
                icon: Icons.circle,
                iconColor: Colors.blue,
                text: pickup,
              ),
              const Divider(height: 16),
              _RouteInfoRow(
                icon: Icons.location_on,
                iconColor: Colors.red,
                text: destination,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _RouteInfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
