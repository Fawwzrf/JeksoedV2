// filepath: lib/app/modules/trip/controllers/trip_completed_controller.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/ride_request.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter/material.dart';

class TripCompletedUiState {
  final bool isLoading;
  final RideRequest? rideRequest;
  final String feedbackText;
  final int totalFare;
  final int deposit;
  final int earnings;
  final bool isSubmitting;

  TripCompletedUiState({
    this.isLoading = true,
    this.rideRequest,
    this.feedbackText = '',
    this.totalFare = 0,
    this.deposit = 0,
    this.earnings = 0,
    this.isSubmitting = false,
  });

  TripCompletedUiState copyWith({
    bool? isLoading,
    RideRequest? rideRequest,
    String? feedbackText,
    int? totalFare,
    int? deposit,
    int? earnings,
    bool? isSubmitting,
  }) {
    return TripCompletedUiState(
      isLoading: isLoading ?? this.isLoading,
      rideRequest: rideRequest ?? this.rideRequest,
      feedbackText: feedbackText ?? this.feedbackText,
      totalFare: totalFare ?? this.totalFare,
      deposit: deposit ?? this.deposit,
      earnings: earnings ?? this.earnings,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class TripCompletedController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var uiState = TripCompletedUiState().obs;
  final String rideRequestId;

  TripCompletedController({required this.rideRequestId});

  @override
  void onInit() {
    super.onInit();
    fetchRideDetails();
  }

  Future<void> fetchRideDetails() async {
    try {
      final snapshot = await _db
          .collection("ride_requests")
          .doc(rideRequestId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final request = RideRequest.fromMap(
          data,
          snapshot.id,
        ); // Calculate payment details
        final totalFare = request.fare;
        final deposit = (totalFare * 0.1).toInt(); // 10% fee
        final earnings = totalFare - deposit;

        uiState.value = uiState.value.copyWith(
          isLoading: false,
          rideRequest: request,
          totalFare: totalFare,
          deposit: deposit,
          earnings: earnings,
        );
      } else {
        uiState.value = uiState.value.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Error fetching ride details: $e');
      uiState.value = uiState.value.copyWith(isLoading: false);
    }
  }

  void finishTripAndUpdateBalance(VoidCallback onFinished) {
    final driverId = uiState.value.rideRequest?.driverId;
    final earnings = uiState.value.earnings;

    if (driverId == null || driverId.isEmpty || earnings <= 0) {
      print('Invalid driver ID or earnings');
      onFinished();
      return;
    }

    uiState.value = uiState.value.copyWith(isSubmitting: true);

    final driverRef = _db.collection("users").doc(driverId);

    _db
        .runTransaction((transaction) async {
          transaction.update(driverRef, {
            'balance': FieldValue.increment(earnings),
          });
        })
        .then((_) {
          print('Driver balance updated successfully');
          uiState.value = uiState.value.copyWith(isSubmitting: false);
          onFinished();
        })
        .catchError((error) {
          print('Error updating driver balance: $error');
          uiState.value = uiState.value.copyWith(isSubmitting: false);
          onFinished();
        });
  }

  void onFeedbackChanged(String text) {
    uiState.value = uiState.value.copyWith(feedbackText: text);
  }

  String getFormattedDate(DateTime? timestamp) {
    if (timestamp == null) return '';
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(timestamp);
  }

  void navigateToDriverMain() {
    Get.offAllNamed(Routes.driverMain);
  }

  void navigateToRating() {
    final request = uiState.value.rideRequest;
    if (request?.driverId != null) {
      Get.toNamed('/rating/${request!.driverId}/$rideRequestId');
    }
  }
}
