// filepath: lib/app/modules/shared/activity/controllers/activity_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../data/models/ride_request.dart';

class RideHistoryDisplay {
  final RideRequest ride;
  final String otherUserName;
  final String? otherUserPhoto;

  RideHistoryDisplay({
    required this.ride,
    required this.otherUserName,
    this.otherUserPhoto,
  });
}

class ActivityUiState {
  final bool isLoading;
  final List<RideHistoryDisplay> rideHistoryItems;
  final List<RideHistoryDisplay> filteredRides;
  final int selectedTab;
  final bool isDriver;

  ActivityUiState({
    this.isLoading = true,
    this.rideHistoryItems = const [],
    this.filteredRides = const [],
    this.selectedTab = 0,
    this.isDriver = false,
  });

  ActivityUiState copyWith({
    bool? isLoading,
    List<RideHistoryDisplay>? rideHistoryItems,
    List<RideHistoryDisplay>? filteredRides,
    int? selectedTab,
    bool? isDriver,
  }) {
    return ActivityUiState(
      isLoading: isLoading ?? this.isLoading,
      rideHistoryItems: rideHistoryItems ?? this.rideHistoryItems,
      filteredRides: filteredRides ?? this.filteredRides,
      selectedTab: selectedTab ?? this.selectedTab,
      isDriver: isDriver ?? this.isDriver,
    );
  }
}

class ActivityController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  var uiState = ActivityUiState().obs;
  StreamSubscription? _historySubscription;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    fetchUserRoleAndHistory();
  }

  @override
  void onClose() {
    _historySubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchUserRoleAndHistory() async {
    if (currentUserId == null) {
      uiState.value = uiState.value.copyWith(isLoading: false);
      return;
    }

    try {
      final userDoc = await _supabase
          .from("users")
          .select('role')
          .eq('id', currentUserId!)
          .single();
      final role = userDoc['role'] as String?;
      await fetchHistory(role);
    } catch (e) {
      print('Error fetching user role: $e');
      uiState.value = uiState.value.copyWith(isLoading: false);
    }
  }

  Future<void> fetchHistory(String? role) async {
    if (role == null || currentUserId == null) return;

    final isDriver = role == "driver";
    uiState.value = uiState.value.copyWith(isDriver: isDriver);

    final fieldToQuery = isDriver
        ? "driver_id"
        : "passenger_id"; // Sesuaikan nama kolom di DB Supabase (snake_case)

    _historySubscription?.cancel();

    // Supabase Realtime Stream
    _historySubscription = _supabase
        .from("ride_requests")
        .stream(primaryKey: ['id'])
        .eq(fieldToQuery, currentUserId!)
        .order("created_at", ascending: false) // Pastikan created_at ada di DB
        .listen(
          (List<Map<String, dynamic>> data) async {
            try {
              // Filter status completed/cancelled di sisi client karena stream terbatas filter-nya
              final filteredData = data
                  .where(
                    (element) =>
                        element['status'] == 'completed' ||
                        element['status'] == 'cancelled',
                  )
                  .toList();

              final historyItems = <RideHistoryDisplay>[];

              for (final rideData in filteredData) {
                final ride = RideRequest.fromJson(rideData); // Gunakan fromJson

                final otherUserId = isDriver ? ride.passengerId : ride.driverId;

                String otherUserName = 'User';
                String? otherUserPhoto;

                if (otherUserId != null) {
                  final userData = await _supabase
                      .from("users")
                      .select("nama, photo_url")
                      .eq("id", otherUserId)
                      .maybeSingle();

                  if (userData != null) {
                    otherUserName =
                        userData['nama'] ?? userData['name'] ?? 'User';
                    otherUserPhoto =
                        userData['photo_url'] ?? userData['photoUrl'];
                  }
                }

                historyItems.add(
                  RideHistoryDisplay(
                    ride: ride,
                    otherUserName: otherUserName,
                    otherUserPhoto: otherUserPhoto,
                  ),
                );
              }

              uiState.value = uiState.value.copyWith(
                isLoading: false,
                rideHistoryItems: historyItems,
              );
              onTabSelected(uiState.value.selectedTab);
            } catch (e) {
              print('Error processing ride history: $e');
            }
          },
          onError: (e) {
            print('Stream error: $e');
          },
        );
  }

  void onTabSelected(int tabIndex) {
    List<RideHistoryDisplay> filtered;

    switch (tabIndex) {
      case 1: // Selesai
        filtered = uiState.value.rideHistoryItems
            .where((item) => item.ride.status == "completed")
            .toList();
        break;
      case 2: // Dibatalkan
        filtered = uiState.value.rideHistoryItems
            .where((item) => item.ride.status == "cancelled")
            .toList();
        break;
      default: // Semua
        filtered = uiState.value.rideHistoryItems;
        break;
    }

    uiState.value = uiState.value.copyWith(
      selectedTab: tabIndex,
      filteredRides: filtered,
    );
  }

  void navigateToDetail(String rideId) {
    Get.toNamed('/activity-detail/$rideId');
  }
}
