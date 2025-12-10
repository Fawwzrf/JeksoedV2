// filepath: lib/app/modules/shared/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileUiState {
  final String name;
  final String email;
  final String photoUrl;
  final bool isLoading;
  final bool showLogoutDialog;
  final bool showDeleteDialog;
  final String? role;

  ProfileUiState({
    this.name = 'Memuat...',
    this.email = 'Memuat...',
    this.photoUrl = '',
    this.isLoading = true,
    this.showLogoutDialog = false,
    this.showDeleteDialog = false,
    this.role,
  });

  ProfileUiState copyWith({
    String? name,
    String? email,
    String? photoUrl,
    bool? isLoading,
    bool? showLogoutDialog,
    bool? showDeleteDialog,
    String? role,
  }) {
    return ProfileUiState(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoading: isLoading ?? this.isLoading,
      showLogoutDialog: showLogoutDialog ?? this.showLogoutDialog,
      showDeleteDialog: showDeleteDialog ?? this.showDeleteDialog,
      role: role ?? this.role,
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
          uiState.value = uiState.value.copyWith(
            name: data['nama'] ?? data['name'] ?? 'Nama tidak ditemukan',
            email: user.email ?? 'Email tidak ditemukan',
            photoUrl: data['photoUrl'] ?? data['photo_url'] ?? '',
            role: data['role'] ?? data['user_type'] ?? 'passenger',
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
