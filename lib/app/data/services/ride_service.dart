import 'dart:async';
import 'package:get/get.dart';
import 'package:jeksoedv2/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/ride_request.dart';
import '../../../utils/app_constants.dart';

// Model helper sederhana
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  LocationData({required this.latitude, required this.longitude, this.address});
}

// Data hasil perhitungan rute
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

  // --- MAPS & ROUTING LOGIC (PERBAIKAN UTAMA) ---

  /// Mendapatkan detail rute (Jarak, Waktu, Polyline)
  /// Dalam implementasi nyata, ini akan memanggil Google Directions API.
  /// Di sini kita menggunakan simulasi cerdas.
  Future<RouteDetails> getRouteDetails({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 1. Hitung Jarak Garis Lurus (Straight Line)
    double distanceInMeters = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    // 2. Terapkan Faktor Koreksi Jalan (Road Curvature Factor)
    // Jalan raya tidak pernah lurus sempurna. Rata-rata faktornya 1.3 - 1.5x
    double roadDistanceKm = (distanceInMeters / 1000) * 1.4;

    // Minimum jarak 1 km
    if (roadDistanceKm < 1.0) roadDistanceKm = 1.0;

    // 3. Hitung Durasi (Asumsi kecepatan rata-rata dalam kota 30 km/jam)
    // Rumus: (Jarak / Kecepatan) * 60 menit + buffer macet
    int durationMins = ((roadDistanceKm / 30) * 60).round();
    durationMins += 5; // Buffer 5 menit untuk lampu merah/macet

    // 4. Simulasi Polyline (Opsional: Nanti diganti API response)
    // Kita kosongkan dulu atau isi dummy string jika ingin test decode
    String polyline = "";

    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));

    return RouteDetails(
      distanceKm: roadDistanceKm,
      durationMins: durationMins,
      encodedPolyline: polyline,
    );
  }

  /// Menghitung Tarif Berdasarkan Jarak & Tipe Kendaraan
  double calculateFare({
    required double distanceKm,
    required RideType rideType,
  }) {
    double baseFare = AppConstants.baseFare;
    double perKmRate = AppConstants.perKmRate;

    switch (rideType) {
      case RideType.premium: // JekMobil
        baseFare = 10000.0;
        perKmRate = 4000.0; // Lebih mahal
        break;
      case RideType.shared:
        perKmRate *= 0.8;
        break;
      default: // JekMotor
        baseFare = 5000.0;
        perKmRate = 2500.0;
        break;
    }

    // Tarif = Basis + (Jarak * Tarif/km)
    double totalFare = baseFare + (distanceKm * perKmRate);

    // Pembulatan ke ribuan terdekat
    return (totalFare / 1000).ceil() * 1000.0;
  }

  // --- END MAPS LOGIC ---

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
    String? encodedPolyline,
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
        'status': 'pending',
        'fare': estimatedFare,
        'distance': estimatedDistance,
        'duration': estimatedDuration,
        'notes': notes,
        'encoded_polyline':
            encodedPolyline, // Simpan polyline untuk digambar di peta
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
      Get.snackbar('Error', 'Gagal membuat permintaan ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // ... (Sisa fungsi _listenToCurrentRide, startLookingForRides, acceptRide, dll tetap sama)
  // ... (Salin sisa kode dari file sebelumnya jika diperlukan, atau biarkan seperti di bawah)

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

            // Handle status notifications logic here...
          }
        });
  }

  void startLookingForRides() {
    _availableRidesSubscription?.cancel();
    _availableRidesSubscription = _supabase
        .from(AppConstants.ridesTable)
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen((List<Map<String, dynamic>> data) {
          // Filter client side untuk memastikan yang belum ada drivernya
          final filteredRides = data
              .where((ride) => ride['driver_id'] == null)
              .map((json) => RideRequest.fromJson(json))
              .toList();

          // Sort by newest
          filteredRides.sort((a, b) {
            final da = a.createdAt ?? DateTime(2000);
            final db = b.createdAt ?? DateTime(2000);
            return db.compareTo(da);
          });

          _availableRides.value = filteredRides;
        }, onError: (error) => print("Error listening rides: $error"));
  }

  void stopLookingForRides() {
    _availableRidesSubscription?.cancel();
    _availableRides.clear();
  }

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

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menerima ride: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateRideStatus(String rideId, RideStatus newStatus) async {
    try {
      final Map<String, dynamic> updates = {
        'status': newStatus.toString().split('.').last,
      };
      if (newStatus == RideStatus.inProgress)
        updates['started_at'] = DateTime.now().toIso8601String();
      if (newStatus == RideStatus.completed)
        updates['completed_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from(AppConstants.ridesTable)
          .update(updates)
          .eq('id', rideId);
      if (newStatus == RideStatus.completed) await loadRideHistory();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelRide(String rideId, {String? reason}) async {
    try {
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
      return true;
    } catch (e) {
      return false;
    }
  }

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
    // Implementasi cek active ride saat startup
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
