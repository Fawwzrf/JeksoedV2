// filepath: lib/app/modules/shared/activity_detail/controllers/activity_detail_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import '../../../../../data/models/ride_request.dart';
import '../../../../../data/models/user_model.dart';

class ActivityDetailUiState {
  final bool isLoading;
  final RideRequest? rideRequest;
  final UserModel? otherUser;
  final bool isChatEnabled;
  final bool isDriver;
  final List<LatLng> polylinePoints;

  ActivityDetailUiState({
    this.isLoading = true,
    this.rideRequest,
    this.otherUser,
    this.isChatEnabled = false,
    this.isDriver = false,
    this.polylinePoints = const [],
  });

  ActivityDetailUiState copyWith({
    bool? isLoading,
    RideRequest? rideRequest,
    UserModel? otherUser,
    bool? isChatEnabled,
    bool? isDriver,
    List<LatLng>? polylinePoints,
  }) {
    return ActivityDetailUiState(
      isLoading: isLoading ?? this.isLoading,
      rideRequest: rideRequest ?? this.rideRequest,
      otherUser: otherUser ?? this.otherUser,
      isChatEnabled: isChatEnabled ?? this.isChatEnabled,
      isDriver: isDriver ?? this.isDriver,
      polylinePoints: polylinePoints ?? this.polylinePoints,
    );
  }
}

class ActivityDetailController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var uiState = ActivityDetailUiState().obs;
  StreamSubscription? _rideSubscription;

  late String rideRequestId;

  @override
  void onInit() {
    super.onInit();
    rideRequestId = Get.parameters['rideRequestId'] ?? '';
    if (rideRequestId.isNotEmpty) {
      fetchRideDetails();
    }
  }

  @override
  void onClose() {
    _rideSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchRideDetails() async {
    _rideSubscription?.cancel();

    // Menggunakan Stream Supabase
    _rideSubscription = _supabase
        .from("ride_requests")
        .stream(primaryKey: ['id'])
        .eq('id', rideRequestId)
        .listen(
          (List<Map<String, dynamic>> data) async {
            if (data.isEmpty) {
              uiState.value = uiState.value.copyWith(isLoading: false);
              return;
            }

            try {
              final rideData = data.first;
              final ride = RideRequest.fromJson(rideData);

              final currentUserId = _supabase.auth.currentUser?.id;
              final isDriver = ride.driverId == currentUserId;
              final otherUserId = isDriver ? ride.passengerId : ride.driverId;

              UserModel? otherUser;
              if (otherUserId != null && otherUserId.isNotEmpty) {
                final userResponse = await _supabase
                    .from("users")
                    .select()
                    .eq("id", otherUserId)
                    .maybeSingle();

                if (userResponse != null) {
                  otherUser = UserModel.fromMap(userResponse, id: otherUserId);
                }
              }

              // Hitung apakah chat aktif (30 menit setelah selesai)
              final completedAt = ride.completedAt?.millisecondsSinceEpoch ?? 0;
              final thirtyMinutesInMillis = 30 * 60 * 1000;
              final isChatEnabled =
                  completedAt > 0 &&
                  (DateTime.now().millisecondsSinceEpoch - completedAt) <
                      thirtyMinutesInMillis;

              // Decode polyline
              List<LatLng> polylinePoints = [];
              if (ride.encodedPolyline != null &&
                  ride.encodedPolyline!.isNotEmpty) {
                try {
                  final decoded = decodePolyline(ride.encodedPolyline!);
                  polylinePoints = decoded
                      .map(
                        (point) =>
                            LatLng(point[0].toDouble(), point[1].toDouble()),
                      )
                      .toList();
                } catch (e) {
                  print('Error decoding polyline: $e');
                }
              }

              uiState.value = ActivityDetailUiState(
                isLoading: false,
                rideRequest: ride,
                otherUser: otherUser,
                isChatEnabled: isChatEnabled,
                isDriver: isDriver,
                polylinePoints: polylinePoints,
              );
            } catch (e) {
              print('Error processing ride details: $e');
              uiState.value = uiState.value.copyWith(isLoading: false);
            }
          },
          onError: (error) {
            print('Error listening to ride details: $error');
            uiState.value = uiState.value.copyWith(isLoading: false);
          },
        );
  }

  String getFormattedRating(UserModel? user) {
    if (user == null || user.ratingCount == 0) return '0.0';
    final avg = user.totalRating / user.ratingCount;
    return avg.toStringAsFixed(1);
  }

  void onChatClick() {
    if (!uiState.value.isChatEnabled) return;
    Get.toNamed('/chat/$rideRequestId');
  }
}
