import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final SupabaseClient _supabase = Supabase.instance.client;
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
      // Fetch Driver
      final driverData = await _supabase
          .from('users')
          .select()
          .eq('id', driverId)
          .maybeSingle();
      UserModel? driver;
      if (driverData != null) {
        driver = UserModel.fromMap(driverData, id: driverId);
      }

      // Fetch Ride
      final rideData = await _supabase
          .from('ride_requests')
          .select()
          .eq('id', rideRequestId)
          .maybeSingle();
      RideRequest? rideRequest;
      if (rideData != null) {
        rideRequest = RideRequest.fromJson(rideData);
      }

      uiState.value = uiState.value.copyWith(
        driver: driver,
        rideRequest: rideRequest,
        isLoading: false,
      );
    } catch (e) {
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
      // Update Ride Request (beri rating)
      await _supabase
          .from('ride_requests')
          .update({
            'rating': rating,
            'passenger_comment':
                uiState.value.comment, // sesuaikan nama kolom DB
          })
          .eq('id', rideRequestId);

      // PENTING: Untuk update rating user, sebaiknya gunakan Database Function (RPC)
      // untuk menghindari race condition. Namun untuk migrasi cepat di sisi klien:

      // 1. Ambil data user terkini
      final userRes = await _supabase
          .from('users')
          .select('total_rating, rating_count')
          .eq('id', driverId)
          .single();
      final currentTotal = (userRes['total_rating'] ?? 0).toDouble();
      final currentCount = (userRes['rating_count'] ?? 0).toInt();

      // 2. Update data user
      await _supabase
          .from('users')
          .update({
            'total_rating': currentTotal + rating,
            'rating_count': currentCount + 1,
          })
          .eq('id', driverId);

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
