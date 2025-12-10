// filepath: lib/app/modules/trip/controllers/trip_completed_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final SupabaseClient _supabase = Supabase.instance.client;

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
      // Ganti _db.collection... dengan _supabase.from...
      final response = await _supabase
          .from("ride_requests")
          .select()
          .eq("id", rideRequestId)
          .maybeSingle();

      if (response != null) {
        final request = RideRequest.fromJson(response);

        final totalFare = request.fare ?? 0; // Handle null safety
        final deposit = (totalFare * 0.1).toInt();
        final earnings = totalFare - deposit;

        uiState.value = uiState.value.copyWith(
          isLoading: false,
          rideRequest: request,
          totalFare: totalFare.toInt(),
          deposit: deposit,
          earnings: earnings.toInt(),
        );
      } else {
        uiState.value = uiState.value.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Error fetching ride details: $e');
      uiState.value = uiState.value.copyWith(isLoading: false);
    }
  }

  void finishTripAndUpdateBalance(VoidCallback onFinished) async {
    final driverId = uiState.value.rideRequest?.driverId;
    final earnings = uiState.value.earnings;

    if (driverId == null) {
      onFinished();
      return;
    }

    uiState.value = uiState.value.copyWith(isSubmitting: true);

    try {
      // 1. Ambil balance driver saat ini
      final userRes = await _supabase
          .from('users')
          .select('balance')
          .eq('id', driverId)
          .single();

      final currentBalance = (userRes['balance'] ?? 0) as int;

      // 2. Update balance baru
      await _supabase
          .from('users')
          .update({'balance': currentBalance + earnings})
          .eq('id', driverId);

      uiState.value = uiState.value.copyWith(isSubmitting: false);
      onFinished();
    } catch (e) {
      print("Error: $e");
      uiState.value = uiState.value.copyWith(isSubmitting: false);
      onFinished();
    }
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
