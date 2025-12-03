// filepath: lib/app/modules/driver/all_orders/controllers/all_orders_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../data/models/ride_request.dart';

class AllOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  var rideRequests = <RideRequest>[].obs;
  var isLoading = true.obs;
  var acceptingRideId = Rxn<String>();

  // Streams
  StreamSubscription<QuerySnapshot>? _rideRequestsStream;

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

  void _startListeningForRides() {
    isLoading.value = true;
    _rideRequestsStream = _firestore
        .collection('ride_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final requests = snapshot.docs.map((doc) {
              final data = doc.data();
              return RideRequest.fromMap(data, doc.id);
            }).toList();

            rideRequests.value = requests;
            isLoading.value = false;
          },
          onError: (error) {
            print('Error listening for rides: $error');
            isLoading.value = false;
            Get.snackbar('Error', 'Failed to load ride requests');
          },
        );
  }

  Future<void> acceptRideRequest(RideRequest rideRequest) async {
    try {
      acceptingRideId.value = rideRequest.id;
      final userId = _auth.currentUser?.uid;

      if (userId == null) throw Exception('Driver not logged in');

      // Update ride request with driver info
      await _firestore.collection('ride_requests').doc(rideRequest.id).update({
        'driverId': userId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

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
