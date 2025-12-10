// filepath: lib/app/modules/driver/all_orders/controllers/all_orders_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../data/models/ride_request.dart';

class AllOrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Observables
  var rideRequests = <RideRequest>[].obs;
  var isLoading = true.obs;
  var acceptingRideId = Rxn<String>();

  // Streams
  StreamSubscription? _rideRequestsStream;

  @override
  void onInit() {
    super.onInit();
    _startListeningForRides();
  }

  @override
  void onClose() {
    _rideRequestsStream?.cancel();
    super.onClose();
  }

  DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
      try {
        return DateTime.parse(s);
      } catch (_) {}
      try {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(s));
      } catch (_) {}
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _startListeningForRides() {
    isLoading.value = true;
    _rideRequestsStream?.cancel();

    _rideRequestsStream = _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        // listen all changes for table then filter client-side for compatibility
        .listen(
          (List<Map<String, dynamic>> data) {
            try {
              final raw = data
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();

              // Keep only pending requests without driver assigned
              final filtered = raw.where((r) {
                final status = (r['status'] ?? r['status'].toString())
                    .toString();
                final driverId = r['driver_id'] ?? r['driverId'];
                return status == 'pending' && (driverId == null);
              }).toList();

              // sort by created_at (safely)
              filtered.sort((a, b) {
                final da = _toDate(a['created_at'] ?? a['createdAt']);
                final db = _toDate(b['created_at'] ?? b['createdAt']);
                return db.compareTo(da); // descending (newest first)
              });

              // Convert to RideRequest model (assumes RideRequest.fromJson exists)
              final requests = filtered
                  .map(
                    (m) => RideRequest.fromJson(Map<String, dynamic>.from(m)),
                  )
                  .toList();

              rideRequests.value = requests;
              isLoading.value = false;
            } catch (e) {
              print('Error processing ride requests stream: $e');
              isLoading.value = false;
            }
          },
          onError: (err) {
            print('Error listening for ride requests: $err');
            isLoading.value = false;
          },
        );
  }

  Future<void> acceptRideRequest(RideRequest rideRequest) async {
    try {
      acceptingRideId.value = rideRequest.id;
      final driverId = _supabase.auth.currentUser?.id;
      if (driverId == null) throw Exception('Driver not logged in');

      // Update ride request with driver info
      await _supabase
          .from('ride_requests')
          .update({
            'driver_id': driverId,
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideRequest.id);

      acceptingRideId.value = null;

      // Navigate to trip screen
      Get.toNamed('/trip/${rideRequest.id}');
    } catch (e) {
      acceptingRideId.value = null;
      Get.snackbar('Error', 'Failed to accept ride: $e');
    }
  }

  void refreshRides() {
    _startListeningForRides();
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }
}
