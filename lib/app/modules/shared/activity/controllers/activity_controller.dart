// filepath: lib/app/modules/shared/activity/controllers/activity_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var uiState = ActivityUiState().obs;
  StreamSubscription<QuerySnapshot>? _historySubscription;

  String? get currentUserId => _auth.currentUser?.uid;

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
      final userDoc = await _db.collection("users").doc(currentUserId).get();
      final role = userDoc.data()?['role'] as String?;
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

    final fieldToQuery = isDriver ? "driverId" : "passengerId";

    _historySubscription?.cancel();
    _historySubscription = _db
        .collection("ride_requests")
        .where(fieldToQuery, isEqualTo: currentUserId)
        .where("status", whereIn: ["completed", "cancelled"])
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              final historyItems = <RideHistoryDisplay>[];

              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  final ride = RideRequest.fromMap(data, doc.id);
                  final otherUserId = isDriver
                      ? ride.passengerId
                      : ride.driverId;
                  if (otherUserId == null || otherUserId.isEmpty) {
                    print(
                      'Ride with ID ${ride.id} is missing other user\'s ID.',
                    );
                    continue;
                  }

                  final userDoc = await _db
                      .collection("users")
                      .doc(otherUserId)
                      .get();
                  final userData = userDoc.data();
                  final otherUserName = userData?['nama'] ?? 'User';
                  final otherUserPhoto = userData?['photoUrl'];

                  historyItems.add(
                    RideHistoryDisplay(
                      ride: ride,
                      otherUserName: otherUserName,
                      otherUserPhoto: otherUserPhoto,
                    ),
                  );
                } catch (e) {
                  print('Error processing ride document: $e');
                }
              }

              uiState.value = uiState.value.copyWith(
                isLoading: false,
                rideHistoryItems: historyItems,
              );

              // Update filtered list
              onTabSelected(uiState.value.selectedTab);
            } catch (e) {
              print('Error processing ride history: $e');
              uiState.value = uiState.value.copyWith(isLoading: false);
            }
          },
          onError: (e) {
            print('Error listening to ride history: $e');
            uiState.value = uiState.value.copyWith(isLoading: false);
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
