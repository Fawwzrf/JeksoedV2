import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_request.dart';
import '../../../utils/app_constants.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  LocationData({required this.latitude, required this.longitude, this.address});
}

enum RideType { standard, premium, shared }

enum RideStatus { requested, accepted, inProgress, completed, cancelled }

enum PaymentMethod { cash, card, wallet, transfer }

class RideService extends GetxService {
  static RideService get to => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Current ride request
  final Rx<RideRequest?> _currentRide = Rx<RideRequest?>(null);
  RideRequest? get currentRide => _currentRide.value;

  // Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Available rides for drivers
  final RxList<RideRequest> _availableRides = <RideRequest>[].obs;
  List<RideRequest> get availableRides => _availableRides;

  // Ride history
  final RxList<RideRequest> _rideHistory = <RideRequest>[].obs;
  List<RideRequest> get rideHistory => _rideHistory;

  // Subscription handles
  StreamSubscription? _availableRidesSubscription;
  StreamSubscription? _currentRideSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    _availableRidesSubscription?.cancel();
    _currentRideSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeService() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await loadRideHistory();
      _checkActiveRide();
    }
  }

  // Cek jika ada order gantung saat aplikasi di-restart
  Future<void> _checkActiveRide() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from(AppConstants.ridesTable)
          .select()
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .inFilter('status', ['requested', 'accepted', 'in_progress'])
          .maybeSingle();

      if (response != null) {
        final ride = RideRequest.fromJson(response);
        _currentRide.value = ride;
        _listenToCurrentRide(ride.id);
      }
    } catch (e) {
      print("Error checking active ride: $e");
    }
  }

  // Request a ride (for passengers)
  Future<bool> requestRide({
    required LocationData pickupLocation,
    required LocationData destinationLocation,
    required RideType rideType,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? notes,
    double estimatedFare = 0,
    double estimatedDistance = 0,
    double estimatedDuration = 0,
  }) async {
    try {
      _isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw "User not logged in";

      // Hitung estimasi fare dari database atau konstanta
      final fare = estimatedFare > 0
          ? estimatedFare
          : calculateEstimatedFare(
              distance: estimatedDistance,
              rideType: rideType,
            );

      final rideData = {
        'passenger_id': userId,
        'pickup_lat': pickupLocation.latitude,
        'pickup_lng': pickupLocation.longitude,
        'pickup_address': pickupLocation.address,
        'dest_lat': destinationLocation.latitude,
        'dest_lng': destinationLocation.longitude,
        'dest_address': destinationLocation.address,
        'ride_type': rideType.toString().split('.').last,
        'payment_method': paymentMethod.toString().split('.').last,
        'status': 'requested',
        'fare': fare,
        'distance': estimatedDistance,
        'duration': estimatedDuration,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(AppConstants.ridesTable)
          .insert(rideData)
          .select()
          .single();

      final newRide = RideRequest.fromJson(response);
      _currentRide.value = newRide;
      _listenToCurrentRide(newRide.id);

      Get.snackbar(
        'Success',
        'Permintaan ride telah dikirim',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat permintaan ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Listener untuk ride yang sedang aktif
  void _listenToCurrentRide(String rideId) {
    _currentRideSubscription?.cancel();
    _currentRideSubscription = _supabase
        .from(AppConstants.ridesTable)
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final updatedRide = RideRequest.fromJson(data.first);
            _currentRide.value = updatedRide;

            switch (updatedRide.status) {
              case RideStatus.accepted:
                Get.snackbar(
                  "Status",
                  "Driver telah menerima pesanan Anda!",
                  snackPosition: SnackPosition.BOTTOM,
                );
                break;
              case RideStatus.inProgress:
                Get.snackbar(
                  "Status",
                  "Perjalanan dimulai",
                  snackPosition: SnackPosition.BOTTOM,
                );
                break;
              case RideStatus.completed:
                Get.snackbar(
                  "Status",
                  "Perjalanan selesai",
                  snackPosition: SnackPosition.BOTTOM,
                );
                loadRideHistory();
                break;
              case RideStatus.cancelled:
                Get.snackbar(
                  "Status",
                  "Perjalanan dibatalkan",
                  snackPosition: SnackPosition.BOTTOM,
                );
                break;
              default:
                break;
            }
          }
        });
  }

  // Start listening untuk available rides (driver)
  void startLookingForRides() {
    _availableRidesSubscription?.cancel();
    _availableRidesSubscription = _supabase
        .from(AppConstants.ridesTable)
        .stream(primaryKey: ['id'])
        .eq('status', 'requested')
        .order('created_at', ascending: false)
        .listen(
          (List<Map<String, dynamic>> data) {
            final filteredRides = data
                .where((ride) => ride['driver_id'] == null)
                .map((json) => RideRequest.fromJson(json))
                .toList();
            _availableRides.value = filteredRides;
          },
          onError: (error) {
            print("Error listening for available rides: $error");
          },
        );
  }

  void stopLookingForRides() {
    _availableRidesSubscription?.cancel();
    _availableRides.clear();
  }

  // Accept a ride (for drivers)
  Future<bool> acceptRide(String rideId) async {
    try {
      _isLoading.value = true;
      final driverId = _supabase.auth.currentUser?.id;
      if (driverId == null) return false;

      final response = await _supabase
          .from(AppConstants.ridesTable)
          .update({
            'driver_id': driverId,
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId)
          .select()
          .single();

      final acceptedRide = RideRequest.fromJson(response);
      _currentRide.value = acceptedRide;
      _listenToCurrentRide(rideId);
      _availableRides.removeWhere((r) => r.id == rideId);

      Get.snackbar(
        'Success',
        'Anda telah menerima pesanan',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menerima ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update ride status
  Future<bool> updateRideStatus(String rideId, RideStatus newStatus) async {
    try {
      _isLoading.value = true;

      final Map<String, dynamic> updates = {
        'status': newStatus.toString().split('.').last,
      };

      if (newStatus == RideStatus.inProgress) {
        updates['started_at'] = DateTime.now().toIso8601String();
      } else if (newStatus == RideStatus.completed) {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from(AppConstants.ridesTable)
          .update(updates)
          .eq('id', rideId);

      if (newStatus == RideStatus.completed) {
        await loadRideHistory();
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal update status: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Cancel ride
  Future<bool> cancelRide(String rideId, {String? reason}) async {
    try {
      _isLoading.value = true;

      await _supabase
          .from(AppConstants.ridesTable)
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId);

      _currentRide.value = null;
      _currentRideSubscription?.cancel();
      await loadRideHistory();

      Get.snackbar(
        'Success',
        'Ride telah dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal membatalkan ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Rate ride
  Future<bool> rateRide(String rideId, int rating, {String? comment}) async {
    try {
      _isLoading.value = true;

      await _supabase
          .from(AppConstants.ridesTable)
          .update({
            'rating': rating,
            'review_comment': comment,
            'rated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId);

      await loadRideHistory();

      Get.snackbar(
        'Success',
        'Terima kasih atas rating Anda',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memberi rating: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Load ride history
  Future<void> loadRideHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from(AppConstants.ridesTable)
          .select()
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .order('created_at', ascending: false)
          .limit(50);

      _rideHistory.value = (response as List)
          .map((json) => RideRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Failed to load history: $e');
    }
  }

  // Calculate estimated fare berdasarkan konstanta
  double calculateEstimatedFare({
    required double distance,
    required RideType rideType,
  }) {
    // Gunakan konstanta dari app_constants.dart
    double baseFare = AppConstants.baseFare;
    double perKmRate = AppConstants.perKmRate;

    switch (rideType) {
      case RideType.premium:
        perKmRate *= AppConstants.premiumMultiplier;
        break;
      case RideType.shared:
        perKmRate *= AppConstants.sharedMultiplier;
        break;
      default:
        break;
    }

    return baseFare + (distance * perKmRate);
  }
}
