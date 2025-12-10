import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_request.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  LocationData({required this.latitude, required this.longitude, this.address});
}

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

      // Cek apakah user sedang punya transaksi aktif (status belum completed/cancelled)
      _checkActiveRide();
    }
  }

  // Cek jika ada order gantung saat aplikasi di-restart
  Future<void> _checkActiveRide() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Cari order aktif dimana user adalah penumpang atau driver
      final response = await _supabase
          .from('rides')
          .select()
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .not(
            'status',
            'in',
            '("completed","cancelled")',
          ) // Filter status aktif
          .maybeSingle(); // Ambil satu jika ada

      if (response != null) {
        final ride = RideRequest.fromJson(response);
        _currentRide.value = ride;
        _listenToCurrentRide(ride.id); // Lanjut dengarkan update
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
        'fare': estimatedFare,
        'distance': estimatedDistance,
        'duration': estimatedDuration,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert ke tabel 'rides' dan kembalikan data single row
      final response = await _supabase
          .from('rides')
          .insert(rideData)
          .select()
          .single();

      // Convert JSON ke Model
      final newRide = RideRequest.fromJson(response);
      _currentRide.value = newRide;

      // Mulai dengarkan perubahan pada ride ini (misal: diterima driver)
      _listenToCurrentRide(newRide.id);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to request ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Listener khusus untuk ride yang sedang aktif (Passenger & Driver)
  void _listenToCurrentRide(String rideId) {
    _currentRideSubscription?.cancel();
    _currentRideSubscription = _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final updatedRide = RideRequest.fromJson(data.first);
            _currentRide.value = updatedRide;

            // Logika notifikasi sederhana perubahan status
            if (updatedRide.status == RideStatus.accepted) {
              Get.snackbar("Status", "Driver telah menerima pesanan Anda!");
            } else if (updatedRide.status == RideStatus.completed) {
              Get.snackbar("Status", "Perjalanan selesai");
              // Refresh history dan clear current ride
              loadRideHistory();
              // _currentRide.value = null; // Opsional: biarkan di layar review dulu
            }
          }
        });
  }

  void startLookingForRides() {
    _availableRidesSubscription?.cancel();
    _availableRidesSubscription = _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', 'requested')
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          _availableRides.value = data
              .map((json) => RideRequest.fromJson(json))
              .toList();
        });
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

      // Update status ride di database
      final response = await _supabase
          .from('rides')
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

      // Driver sekarang memantau ride ini
      _listenToCurrentRide(rideId);

      // Hapus dari list available secara lokal (stream akan update otomatis juga)
      _availableRides.removeWhere((r) => r.id == rideId);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept ride: $e');
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

      await _supabase.from('rides').update(updates).eq('id', rideId);

      if (newStatus == RideStatus.completed) {
        // Refresh history
        loadRideHistory();
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
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
          .from('rides')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId);

      _currentRide.value = null;
      _currentRideSubscription?.cancel();
      loadRideHistory();

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Rate ride
  Future<bool> rateRide(String rideId, int rating, {String? comment}) async {
    try {
      _isLoading.value = true;

      // Asumsi: Anda punya kolom 'rating' dan 'review_comment' di tabel 'rides'
      // Atau tabel terpisah 'reviews'. Di sini kita update tabel rides.
      await _supabase
          .from('rides')
          .update({'rating': rating, 'review_comment': comment})
          .eq('id', rideId);

      // Update lokal history jika perlu
      final index = _rideHistory.indexWhere((r) => r.id == rideId);
      if (index != -1) {
        // Refresh history dari server agar data sinkron
        loadRideHistory();
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to rate ride: $e');
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

      // Ambil history dimana user adalah passenger ATAU driver
      final response = await _supabase
          .from('rides')
          .select()
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .order('created_at', ascending: false)
          .limit(20); // Limit untuk performa

      _rideHistory.value = (response as List)
          .map((json) => RideRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Failed to load history: $e');
    }
  }

  // Calculate estimated fare
  double calculateEstimatedFare({
    required double distance,
    required RideType rideType,
  }) {
    double baseFare = 5000.0;
    double perKmRate = 2000.0;

    switch (rideType) {
      case RideType.premium:
        perKmRate *= 1.5;
        break;
      case RideType.shared:
        perKmRate *= 0.8;
        break;
      default:
        break;
    }
    return baseFare + (distance * perKmRate);
  }
}
