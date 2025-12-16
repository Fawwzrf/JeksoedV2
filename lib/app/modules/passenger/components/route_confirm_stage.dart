import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../utils/app_colors.dart';

class RouteConfirmStage extends StatelessWidget {
  final Map<String, String>? routeInfo;
  final VoidCallback onCreateOrderClick;

  const RouteConfirmStage({
    super.key,
    required this.routeInfo,
    required this.onCreateOrderClick,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header JekMotor
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/motor_icon.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 16),
                const Text(
                  'JekMotor',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(height: 32),

            // Detail Informasi Pesanan
            Column(
              children: [
                _InfoRow(
                  label: 'Estimasi Biaya',
                  value: routeInfo?['price'] ?? '-',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Jarak',
                  value: routeInfo?['distance'] ?? '-',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Estimasi Waktu',
                  value: routeInfo?['duration'] ?? '-',
                ),
                const SizedBox(height: 16),
                const _InfoRow(
                  label: 'Kapasitas',
                  value: '1 orang',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Metode Pembayaran',
                  valueWidget: Expanded(
                    child: Row(
                      children: const [
                        
                        Spacer(),
                        Text(
                          'Cash (Tunai)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.payments, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                      ],
                    ),
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
                  backgroundColor: const Color(0xFFFFC107), // Yellow
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lanjut bro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        valueWidget ??
            Text(
              value ?? '-',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
      ],
    );
  }
}
