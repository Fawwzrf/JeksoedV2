// filepath: lib/app/modules/rating/controllers/rating_controller.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/ride_request.dart';
import '../../../../data/models/user_model.dart';

class RatingUiState {
  final int selectedRating;
  final String comment;
  final bool isSubmitting;
  final String? error;
  final UserModel? driver;
  final RideRequest? rideRequest;
  final bool isLoading;

  RatingUiState({
    this.selectedRating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.error,
    this.driver,
    this.rideRequest,
    this.isLoading = true,
  });

  RatingUiState copyWith({
    int? selectedRating,
    String? comment,
    bool? isSubmitting,
    String? error,
    UserModel? driver,
    RideRequest? rideRequest,
    bool? isLoading,
  }) {
    return RatingUiState(
      selectedRating: selectedRating ?? this.selectedRating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      driver: driver ?? this.driver,
      rideRequest: rideRequest ?? this.rideRequest,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RatingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String driverId;
  final String rideRequestId;

  var uiState = RatingUiState().obs;

  RatingController({required this.driverId, required this.rideRequestId});

  @override
  void onInit() {
    super.onInit();
    fetchTripAndDriverDetails();
  }

  Future<void> fetchTripAndDriverDetails() async {
    uiState.value = uiState.value.copyWith(isLoading: true);

    try {
      // Fetch driver details
      final driverDoc = await _firestore
          .collection('users')
          .doc(driverId)
          .get();

      UserModel? driver;
      if (driverDoc.exists) {
        final driverData = driverDoc.data() as Map<String, dynamic>;
        driver = UserModel.fromMap(driverData, id: driverId);
      }

      // Fetch ride request details
      final rideDoc = await _firestore
          .collection('ride_requests')
          .doc(rideRequestId)
          .get();

      RideRequest? rideRequest;
      if (rideDoc.exists) {
        final rideData = rideDoc.data() as Map<String, dynamic>;
        rideRequest = RideRequest.fromMap(rideData, rideRequestId);
      }

      uiState.value = uiState.value.copyWith(
        driver: driver,
        rideRequest: rideRequest,
        isLoading: false,
      );
    } catch (e) {
      print('Error fetching trip and driver details: $e');
      uiState.value = uiState.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void onRatingChanged(int newRating) {
    uiState.value = uiState.value.copyWith(selectedRating: newRating);
  }

  void onCommentChanged(String newComment) {
    uiState.value = uiState.value.copyWith(comment: newComment);
  }

  Future<void> submitRating() async {
    final rating = uiState.value.selectedRating;
    if (rating == 0) return;

    uiState.value = uiState.value.copyWith(isSubmitting: true);

    try {
      final driverRef = _firestore.collection('users').doc(driverId);
      final rideRef = _firestore.collection('ride_requests').doc(rideRequestId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(driverRef);

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final currentTotalRating = (data['totalRating'] ?? 0) as int;
          final currentRatingCount = (data['ratingCount'] ?? 0) as int;

          transaction.update(driverRef, {
            'totalRating': currentTotalRating + rating,
            'ratingCount': currentRatingCount + 1,
          });
        }

        transaction.update(rideRef, {
          'rating': rating,
          'passengerComment': uiState.value.comment,
        });
      });

      print('Rating submitted successfully');
      uiState.value = uiState.value.copyWith(isSubmitting: false);
    } catch (e) {
      print('Error submitting rating: $e');
      uiState.value = uiState.value.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }
}
