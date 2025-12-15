import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/ride_request.dart';

class FindingDriverController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  // Observable variables
  final isSearching = true.obs;
  final searchDuration = 0.obs;
  final estimatedArrival = ''.obs;
  final searchStatus = 'Looking for nearby drivers...'.obs;

  // Timers & Subscriptions
  Timer? _durationTimer;
  final rotationValue = 0.0.obs; // Untuk animasi loading
  Timer? _rotationTimer;
  StreamSubscription? _rideSubscription;

  // Driver info
  final driverName = ''.obs;
  final driverRating = ''.obs;
  final driverTrips = ''.obs;
  final vehicleInfo = ''.obs;
  final pickupAddress = ''.obs;
  final destinationAddress = ''.obs;
  final estimatedPrice = ''.obs;

  late String rideRequestId;

  @override
  void onInit() {
    super.onInit();
    // Ambil ID dari parameter URL
    rideRequestId = Get.parameters['rideRequestId'] ?? '';

    if (rideRequestId.isEmpty) {
      Get.back();
      Get.snackbar('Error', 'ID Order tidak valid');
      return;
    }

    _startRotationAnimation();
    _startDurationCounter();
    _listenToRideStatus();
  }

  @override
  void onClose() {
    _stopAllTimers();
    _stopRotationAnimation();
    super.onClose();
  }

  void _listenToRideStatus() {
    _rideSubscription = _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .eq('id', rideRequestId)
        .listen((List<Map<String, dynamic>> data) async {
          if (data.isEmpty) return;

          try {
            final ride = RideRequest.fromJson(data.first);

            // Update info UI dari data DB
            pickupAddress.value = ride.pickupAddress ?? '';
            destinationAddress.value = ride.destAddress ?? '';
            estimatedPrice.value = 'Rp ${ride.fare}';

            // Cek Status
            if (ride.status == 'accepted' && ride.driverId != null) {
              isSearching.value = false;
              _stopRotationAnimation();

              await _fetchDriverInfo(ride.driverId!);

              // Beri waktu user melihat "Driver Found" sebelum pindah
              Future.delayed(const Duration(seconds: 3), () {
                Get.offNamed('/trip/$rideRequestId');
              });
            } else if (ride.status == 'cancelled') {
              Get.offAllNamed('/passenger-main');
              Get.snackbar('Info', 'Order dibatalkan');
            }
          } catch (e) {
            print("Error processing ride update: $e");
          }
        });
  }

  Future<void> _fetchDriverInfo(String driverId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', driverId)
          .single();

      driverName.value = data['name'] ?? data['nama'] ?? 'Driver';
      final rating = data['total_rating'] ?? 0.0;
      final count = data['rating_count'] ?? 1;
      // Hindari pembagian nol
      final avgRating = count > 0 ? (rating / count).toDouble() : 5.0;
      driverRating.value = avgRating.toStringAsFixed(1);
      vehicleInfo.value = data['license_plate'] ?? data['vehicle_plate'] ?? '';
      driverTrips.value = '${data['completed_trips'] ?? 0} trip';
      estimatedArrival.value = '5 menit';

      searchStatus.value = 'Driver ditemukan!';
    } catch (e) {
      print('Error fetching driver info: $e');
    }
  }

  void _startDurationCounter() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      searchDuration.value++;
    });
  }

  void _startRotationAnimation() {
    _rotationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      rotationValue.value = (rotationValue.value + 0.02) % (2 * 3.14159);
    });
  }

  void _stopAllTimers() {
    _durationTimer?.cancel();
    _rotationTimer?.cancel();
  }

  void _stopRotationAnimation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  // User actions
  void cancelSearch() {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pencarian driver?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tidak')),
          TextButton(
            onPressed: () async {
              Get.back(); // Tutup dialog dulu
              await _cancelRideRequestInBackend();
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRideRequestInBackend() async {
    try {
      await _supabase
          .from('ride_requests')
          .update({'status': 'cancelled'})
          .eq('id', rideRequestId);
    } catch (e) {
      Get.snackbar('Error', 'Gagal membatalkan pesanan: $e');
    }
  }

  // Helper methods
  String get formattedDuration {
    final minutes = searchDuration.value ~/ 60;
    final seconds = searchDuration.value % 60;
    return '${minutes}m ${seconds}s';
  }
}
