// filepath: lib/app/modules/shared/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ProfileUiState {
  final String name;
  final String email;
  final String photoUrl;
  final bool isLoading;
  final bool showLogoutDialog;
  final bool showDeleteDialog;
  final String? userType;

  final String rating;
  final String totalTrips;
  final String joinDate;

  ProfileUiState({
    this.name = 'Memuat...',
    this.email = 'Memuat...',
    this.photoUrl = '',
    this.isLoading = true,
    this.showLogoutDialog = false,
    this.showDeleteDialog = false,
    this.userType,
    this.rating = '0.0',
    this.totalTrips = '0',
    this.joinDate = '-',
  });

  ProfileUiState copyWith({
    String? name,
    String? email,
    String? photoUrl,
    bool? isLoading,
    bool? showLogoutDialog,
    bool? showDeleteDialog,
    String? userType,
    String? rating,
    String? totalTrips,
    String? joinDate,
  }) {
    return ProfileUiState(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoading: isLoading ?? this.isLoading,
      showLogoutDialog: showLogoutDialog ?? this.showLogoutDialog,
      showDeleteDialog: showDeleteDialog ?? this.showDeleteDialog,
      userType: userType ?? this.userType,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  var uiState = ProfileUiState().obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from("users")
            .select()
            .eq("id", user.id)
            .maybeSingle();

        if (data != null) {
          // Hitung Rating
          final totalRating = (data['total_rating'] ?? 0).toDouble();
          final ratingCount = (data['rating_count'] ?? 0).toInt();
          final avgRating = ratingCount > 0 ? totalRating / ratingCount : 5.0;

          // Format Tanggal Gabung (ambil tahun saja)
          String joinedYear = '-';
          if (data['created_at'] != null) {
            final date = DateTime.parse(data['created_at']);
            joinedYear = DateFormat('yyyy').format(date);
          }

          uiState.value = uiState.value.copyWith(
            name: data['name'] ?? 'Nama tidak ditemukan',
            email: user.email ?? 'Email tidak ditemukan',
            photoUrl: data['photoUrl'] ?? data['photo_url'] ?? '',
            userType: data['userType'] ?? data['user_type'] ?? 'passenger',
            rating: avgRating.toStringAsFixed(1),
            totalTrips: (data['completed_trips'] ?? 0).toString(),
            joinDate: joinedYear,
            isLoading: false,
          );
        } else {
          // Handle empty data
          uiState.value = uiState.value.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      uiState.value = uiState.value.copyWith(
        name: 'Gagal memuat',
        isLoading: false,
      );
    }
  }

  void onLogoutClick() {
    uiState.value = uiState.value.copyWith(showLogoutDialog: true);
  }

  void onDismissLogoutDialog() {
    uiState.value = uiState.value.copyWith(showLogoutDialog: false);
  }

  void onDeleteClick() {
    uiState.value = uiState.value.copyWith(showDeleteDialog: true);
  }

  void onDismissDeleteDialog() {
    uiState.value = uiState.value.copyWith(showDeleteDialog: false);
  }

  Future<void> confirmLogout() async {
    try {
      await _supabase.auth.signOut();
      onDismissLogoutDialog();
      Get.offAllNamed('/cta');
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e');
      onDismissLogoutDialog();
    }
  }

  Future<void> confirmDeleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from("users").delete().eq("id", user.id);
        await _supabase.auth.signOut();

        onDismissDeleteDialog();
        Get.offAllNamed('/cta');
      }
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar('Error', 'Gagal menghapus akun: $e');
      onDismissDeleteDialog();
    }
  }

  void navigateToEditProfile() {
    // Get.toNamed('/edit-profile');
    Get.snackbar(
      'Edit Profile',
      'Fitur edit profil akan tersedia di versi selanjutnya',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToAbout() {
    Get.snackbar(
      'About',
      'Tentang JekSoed akan tersedia di versi selanjutnya',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToTnc() {
    Get.toNamed('/tnc');
  }
}
