// filepath: lib/app/modules/trip/components/trip_passenger_sheet.dart

import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import '../../../../utils/app_colors.dart';

class TripPassengerSheet extends StatelessWidget {
  final TripUiState uiState;
  final VoidCallback onCancelTrip;
  final VoidCallback onChatClick;

  const TripPassengerSheet({
    super.key,
    required this.uiState,
    required this.onCancelTrip,
    required this.onChatClick,
  });

  @override
  Widget build(BuildContext context) {
    final rideRequest = uiState.rideRequest;
    if (rideRequest == null) return const SizedBox.shrink();

    final driver = uiState.otherUser;
    final isCancelDisabled = rideRequest.status == 'started';

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trip Status
            Text(
              _getStatusText(rideRequest.status),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: driver?.photoUrl != null
                      ? NetworkImage(driver!.photoUrl!)
                      : null,
                  child: driver?.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver?.nama ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        driver?.licensePlate ?? '...',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _getDriverRating(driver),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onChatClick,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.chat, color: Colors.black),
                ),
              ],
            ),

            const Divider(height: 24),

            // Route Display
            Column(
              children: [
                _buildRouteRow(
                  Icons.radio_button_checked,
                  Colors.blue,
                  rideRequest.pickupAddress,
                ),
                const SizedBox(height: 8),
                _buildRouteRow(
                  Icons.location_on,
                  Colors.red,
                  rideRequest.destinationAddress,
                ),
              ],
            ),

            const Divider(height: 24),

            // Payment Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Rp${rideRequest.fare}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCancelDisabled ? null : onCancelTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCancelDisabled ? Colors.grey : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isCancelDisabled
                      ? 'Tidak dapat dibatalkan'
                      : 'Batalkan Perjalanan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(address, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Driver menuju lokasimu';
      case 'arrived':
        return 'Driver telah sampai';
      case 'started':
        return 'Kalian sedang dalam perjalanan';
      default:
        return 'Memuat status...';
    }
  }

  String _getDriverRating(driver) {
    if (driver == null || driver.ratingCount == 0) return '0.0';
    final avg = driver.totalRating / driver.ratingCount;
    return avg.toStringAsFixed(1);
  }
}
