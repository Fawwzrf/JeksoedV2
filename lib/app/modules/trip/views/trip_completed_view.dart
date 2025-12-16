// filepath: lib/app/modules/trip/views/trip_completed_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/trip_completed_controller.dart';
import '../../../../utils/app_colors.dart';

class TripCompletedView extends GetView<TripCompletedController> {
  const TripCompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uiState = controller.uiState.value;

      return TripCompletedScreenUI(
        uiState: uiState,
        formattedDate: controller.getFormattedDate(
          uiState.rideRequest?.createdAt,
        ),
        onFeedbackChange: controller.onFeedbackChanged,
        onFinishClick: () {
          controller.finishTripAndUpdateBalance(() {
            controller.navigateToDriverMain();
          });
        },
      );
    });
  }
}

class TripCompletedScreenUI extends StatelessWidget {
  final TripCompletedUiState uiState;
  final String formattedDate;
  final Function(String) onFeedbackChange;
  final VoidCallback onFinishClick;

  const TripCompletedScreenUI({
    super.key,
    required this.uiState,
    required this.formattedDate,
    required this.onFeedbackChange,
    required this.onFinishClick,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Header with icon and title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Cihuy Selesai!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: uiState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildRideSummaryCard(),
                            const SizedBox(height: 16),
                            _buildFeedbackCard(),
                          ],
                        ),
                      ),
              ),

              // Finish button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: uiState.isSubmitting ? null : onFinishClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: uiState.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          'Selesai',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideSummaryCard() {
    final orderNumber =
        uiState.rideRequest?.id.substring(0, 8) ?? 'JR-FN-00001';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number with copy button
            Row(
              children: [
                Text(
                  'No. Pesanan: $orderNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: orderNumber));
                    Get.snackbar(
                      'Copied',
                      'Order number copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Icon(
                    Icons.content_copy,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(formattedDate, style: const TextStyle(color: Colors.grey)),
              ],
            ),

            const Divider(height: 24),

            // Route info
            Column(
              children: [
                _buildRouteRow(
                  Icons.radio_button_checked,
                  Colors.blue,
                  uiState.rideRequest?.pickupAddress ?? 'Pickup Location',
                ),
                const SizedBox(height: 8),
                _buildRouteRow(
                  Icons.location_on,
                  Colors.red,
                  uiState.rideRequest?.destinationAddress ?? 'Destination',
                ),
              ],
            ),

            const Divider(height: 24),

            // Payment breakdown
            Column(
              children: [
                _buildPaymentRow(
                  'Total Tarif',
                  _formatCurrency(uiState.totalFare),
                ),
                const SizedBox(height: 8),
                _buildPaymentRow(
                  'Potongan Platform (10%)',
                  _formatCurrency(uiState.deposit),
                ),
                const Divider(height: 16),
                _buildPaymentRow(
                  'Pendapatan',
                  _formatCurrency(uiState.earnings),
                  isBold: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text(
                'Detail Pesanan >',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Penumpangnya aman?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: onFeedbackChange,
              decoration: const InputDecoration(
                hintText: 'Ceritakan pengalaman perjalananmu...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String location) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(location, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    if (amount == 0) return 'Rp0';
    return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
