// filepath: lib/app/modules/rating/views/rating_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/rating_controller.dart';
import '../../../../data/models/ride_request.dart';
import '../../../routes/app_pages.dart';

class RatingView extends GetView<RatingController> {
  const RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uiState = controller.uiState.value;

      if (uiState.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return RatingScreenUI(
        uiState: uiState,
        onRatingChange: controller.onRatingChanged,
        onCommentChange: controller.onCommentChanged,
        onSubmitClick: () => _handleSubmitRating(context),
      );
    });
  }

  Future<void> _handleSubmitRating(BuildContext context) async {
    await controller.submitRating();

    if (!context.mounted) return;

    if (controller.uiState.value.error == null &&
        !controller.uiState.value.isSubmitting) {
      _showTripFinishedDialog(context);
    }
  }

  void _showTripFinishedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TripFinishedDialog(
          onDismiss: () {
            Navigator.of(context).pop();
            Get.offAllNamed(Routes.passengerMain);
          },
        );
      },
    );
  }
}

class RatingScreenUI extends StatelessWidget {
  final RatingUiState uiState;
  final Function(int) onRatingChange;
  final Function(String) onCommentChange;
  final VoidCallback onSubmitClick;

  const RatingScreenUI({
    super.key,
    required this.uiState,
    required this.onRatingChange,
    required this.onCommentChange,
    required this.onSubmitClick,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Title
              const Text(
                'Kamu udah sampai di tujuanmu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Driver Info
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: uiState.driver?.photoUrl != null
                    ? CachedNetworkImageProvider(uiState.driver!.photoUrl!)
                    : null,
                child: uiState.driver?.photoUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                uiState.driver?.nama ?? 'Driver',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                uiState.driver?.licensePlate ?? '...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Route and Payment
              RouteAndPayment(ride: uiState.rideRequest),
              const SizedBox(height: 32),

              // Rating
              const Text(
                'Gimana perjalananmu?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              RatingStars(
                rating: uiState.selectedRating,
                onRatingChange: onRatingChange,
              ),
              const SizedBox(height: 24),

              // Comment
              TextField(
                onChanged: onCommentChange,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ada pesan buat Kak Driver ga?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: uiState.selectedRating > 0 && !uiState.isSubmitting
                      ? onSubmitClick
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: uiState.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          'Selesaikan Perjalanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteAndPayment extends StatelessWidget {
  final RideRequest? ride;

  const RouteAndPayment({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Pickup Location
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride?.pickupAddress ?? 'Lokasi Jemput',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Destination Location
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride?.destinationAddress ?? 'Lokasi Tujuan',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total pembayaran',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                'Rp${ride?.fare ?? 0}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChange;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onRatingChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () => onRatingChange(starIndex),
          child: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            size: 48,
            color: starIndex <= rating ? const Color(0xFFFFC107) : Colors.grey,
          ),
        );
      }),
    );
  }
}

class TripFinishedDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const TripFinishedDialog({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo placeholder (you can add your app logo here)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 40, color: Colors.black),
          ),
          const SizedBox(height: 16),

          const Text(
            'Perjalanan Selesai 🏍️✨',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          const Text(
            'Makasih udah pakai JEKSOED! Semoga kita ketemu lagi di perjalanan selanjutnya ♥️',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Kembali ke Home',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
