import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class RouteInfo {
  final String? price;
  final String? distance;
  final String? duration;

  RouteInfo({this.price, this.distance, this.duration});
}

class RouteConfirmStage extends StatelessWidget {
  final RouteInfo? routeInfo;
  final VoidCallback onCreateOrderClick;

  const RouteConfirmStage({
    super.key,
    required this.routeInfo,
    required this.onCreateOrderClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header JekMotor
          Row(
            children: [
              Icon(Icons.motorcycle, color: AppColors.primary, size: 28),
              const SizedBox(width: 16),
              const Text(
                "JekMotor",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Divider(height: 32),

          // Detail Informasi Pesanan
          Column(
            children: [
              InfoRow(label: "Estimasi Biaya", value: routeInfo?.price ?? "-"),
              const SizedBox(height: 16),
              InfoRow(label: "Jarak", value: routeInfo?.distance ?? "-"),
              const SizedBox(height: 16),
              InfoRow(label: "Kapasitas", value: "1 orang"),
              const SizedBox(height: 16),
              InfoRow(
                label: "Metode Pembayaran",
                valueWidget: Row(
                  children: [
                    Icon(Icons.payments, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Tunai",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Order Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onCreateOrderClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Pesan Sekarang",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const InfoRow({super.key, required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
        valueWidget ??
            Text(
              value ?? "-",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
      ],
    );
  }
}
