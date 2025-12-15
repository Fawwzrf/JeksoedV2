import 'dart:async';
import 'package:get/get.dart';
import 'package:jeksoedv2/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// PASTIKAN IMPORT INI MENGARAH KE FILE MODEL YANG BARU KITA PERBAIKI
import '../../../../data/models/ride_request.dart';
import '../../../utils/app_constants.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  LocationData({required this.latitude, required this.longitude, this.address});
}

class RouteDetails {
  final double distanceKm;
  final int durationMins;
  final String encodedPolyline;

  RouteDetails({
    required this.distanceKm,
    required this.durationMins,
    required this.encodedPolyline,
  });
}

enum RideType { standard, premium, shared }

enum RideStatus { requested, accepted, inProgress, completed, cancelled }

enum PaymentMethod { cash, card, wallet, transfer }

class RideService extends GetxService {
  static RideService get to => Get.find();
  final SupabaseClient _supabase = Supabase.instance.client;

  // State Variables
  final Rx<RideRequest?> _currentRide = Rx<RideRequest?>(null);
  RideRequest? get currentRide => _currentRide.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxList<RideRequest> _availableRides = <RideRequest>[].obs;
  List<RideRequest> get availableRides => _availableRides;

  final RxList<RideRequest> _rideHistory = <RideRequest>[].obs;
  List<RideRequest> get rideHistory => _rideHistory;

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

  // --- MAPS & ROUTING LOGIC ---
  Future<RouteDetails> getRouteDetails({
    required LatLng origin,
    required LatLng destination,
  }) async {
    double distanceInMeters = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    double roadDistanceKm = (distanceInMeters / 1000) * 1.4;
    if (roadDistanceKm < 1.0) roadDistanceKm = 1.0;
    int durationMins = ((roadDistanceKm / 30) * 60).round() + 5;

    // Simulasi Polyline
    String polyline = "";
    await Future.delayed(const Duration(milliseconds: 500));

    return RouteDetails(
      distanceKm: roadDistanceKm,
      durationMins: durationMins,
      encodedPolyline: polyline,
    );
  }

  double calculateFare({
    required double distanceKm,
    required RideType rideType,
  }) {
    double baseFare = AppConstants.baseFare;
    double perKmRate = AppConstants.perKmRate;

    switch (rideType) {
      case RideType.premium:
        baseFare = 10000.0;
        perKmRate = 4000.0;
        break;
      case RideType.shared:
        perKmRate *= 0.8;
        break;
      default:
        baseFare = 5000.0;
        perKmRate = 2500.0;
        break;
    }
    double totalFare = baseFare + (distanceKm * perKmRate);
    return (totalFare / 1000).ceil() * 1000.0;
  }

  // Request a ride
  Future<bool> requestRide({
    required LocationData pickupLocation,
    required LocationData destinationLocation,
    required RideType rideType,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? notes,
    double estimatedFare = 0,
    double estimatedDistance = 0,
    double estimatedDuration = 0,
    String? encodedPolyline,
  }) async {
    try {
      _isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) throw "User not logged in";

      // Ambil nama user untuk disimpan di ride request agar driver bisa lihat
      final userProfile = await _supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .single();
      final passengerName = userProfile['name'] ?? 'Penumpang';

      final rideData = {
        'passenger_id': user.id,
        'passenger_name': passengerName, // Penting untuk UI Driver
        'pickup_lat': pickupLocation.latitude,
        'pickup_lng': pickupLocation.longitude,
        'pickup_address': pickupLocation.address,
        'dest_lat': destinationLocation.latitude,
        'dest_lng': destinationLocation.longitude,
        'dest_address': destinationLocation.address,
        'ride_type': rideType.toString().split('.').last,
        'payment_method': paymentMethod.toString().split('.').last,
        'status': 'pending',
        'fare': estimatedFare.toInt(), // Simpan sebagai int
        'distance': estimatedDistance,
        'duration': estimatedDuration.toInt(),
        'notes': notes,
        'encoded_polyline': encodedPolyline,
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
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );

      return true;
    } catch (e) {
      print("Request ride error: $e");
      Get.snackbar('Error', 'Gagal membuat permintaan ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

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
          }
        });
  }

  // Sisa method lainnya (acceptRide, loadRideHistory dll)
  // Pastikan menggunakan RideRequest.fromJson dari model baru
  Future<void> loadRideHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final response = await _supabase
          .from(AppConstants.ridesTable)
          .select()
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .order('created_at', ascending: false)
          .limit(20);
      _rideHistory.value = (response as List)
          .map((json) => RideRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Failed load history: $e');
    }
  }

  Future<void> _checkActiveRide() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
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
    }
  }
}
