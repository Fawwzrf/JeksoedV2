// filepath: lib/app/modules/trip/components/trip_driver_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import 'slide_to_confirm_button.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/currency_formatter.dart';

class TripDriverBottomSheet extends StatefulWidget {
  final TripUiState uiState;
  final Function(String) onUpdateStatus;
  final VoidCallback onCancelTrip;
  final VoidCallback onChatClick;

  const TripDriverBottomSheet({
    super.key,
    required this.uiState,
    required this.onUpdateStatus,
    required this.onCancelTrip,
    required this.onChatClick,
  });

  @override
  State<TripDriverBottomSheet> createState() => _TripDriverBottomSheetState();
}

class _TripDriverBottomSheetState extends State<TripDriverBottomSheet> {
  bool showCancelDialog = false;

  @override
  Widget build(BuildContext context) {
    final rideRequest = widget.uiState.rideRequest;
    if (rideRequest == null) return const SizedBox.shrink();

    final passenger = widget.uiState.otherUser;

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
            // Passenger Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: passenger?.photoUrl != null
                      ? NetworkImage(passenger!.photoUrl!)
                      : null,
                  child: passenger?.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    passenger?.name ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onChatClick,
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

            // Status-specific content
            _buildStatusContent(rideRequest),

            // Cancel button (only if trip not completed)
            if (rideRequest.status != 'completed') ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => showCancelDialog = true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(
                  'Batalkan Perjalanan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
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

  Widget _buildStatusContent(dynamic rideRequest) {
    final formattedPrice = formatCurrency(rideRequest.fare ?? 0);
    final isLoading = widget.uiState.isUpdating; // Ambil status loading

    switch (rideRequest.status) {
      case 'accepted':
        return _buildActionSection(
          // PENTING: Key unik agar widget di-rebuild ulang saat status berubah
          key: const ValueKey('btn_arrived'),
          totalPayment: formattedPrice,
          buttonText: 'Geser jika sudah sampai',
          isLoading: isLoading,
          onSlideConfirmed: () => widget.onUpdateStatus('arrived'),
        );

      case 'arrived':
        return _buildActionSection(
          key: const ValueKey('btn_started'),
          totalPayment: formattedPrice,
          buttonText: 'Geser untuk memulai',
          isLoading: isLoading,
          onSlideConfirmed: () => widget.onUpdateStatus('started'),
        );

      case 'started':
        return _buildActionSection(
          key: const ValueKey('btn_completed'),
          totalPayment: formattedPrice,
          buttonText: 'Geser jika sudah sampai',
          isLoading: isLoading,
          onSlideConfirmed: () => widget.onUpdateStatus('completed'),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionSection({
    required Key key, // Tambahkan parameter Key
    required String totalPayment,
    required String buttonText,
    required bool isLoading, // Tambahkan parameter isLoading
    required VoidCallback onSlideConfirmed,
  }) {
    return Column(
      key: key, // Pasang key di sini
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total pembayaran',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              totalPayment,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Pass isLoading ke tombol
        SlideToConfirmButton(
          text: buttonText,
          isLoading: isLoading,
          onConfirmed: onSlideConfirmed,
        ),
      ],
    );
  }
}
