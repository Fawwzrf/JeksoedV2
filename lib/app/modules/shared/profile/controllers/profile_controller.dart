// filepath: lib/app/modules/shared/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:jeksoedv2/app/routes/app_pages.dart';

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
    Get.toNamed(Routes.editProfile);
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

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final photoUrl = ''.obs;
  final pickedImage = Rx<File?>(null);

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      final state = profileController.uiState.value;
      nameController.text = state.name;
      emailController.text = state.email;
      photoUrl.value = state.photoUrl;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Kosongkan inisialisasi Get.find di onInit, pindahkan ke onReady
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      pickedImage.value = File(picked.path);
    }
  }

  Future<String?> uploadPhoto(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return null;
      final fileExt = file.path.split('.').last;
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storageRes = await supabase.storage.from('profile-photos').upload(fileName, file);
      if (storageRes.isEmpty) return null;
      final publicUrl = supabase.storage.from('profile-photos').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      Get.snackbar('Error', 'Gagal upload foto: $e');
      return null;
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      String? uploadedPhotoUrl = photoUrl.value;
      if (pickedImage.value != null) {
        final url = await uploadPhoto(pickedImage.value!);
        if (url != null) uploadedPhotoUrl = url;
      }
      if (user != null) {
        await supabase.from('users').update({
          'name': nameController.text,
          'email': emailController.text,
          'photo_url': uploadedPhotoUrl,
        }).eq('id', user.id);
        // Update email jika berubah
        if (user.email != emailController.text) {
          await supabase.auth.updateUser(UserAttributes(email: emailController.text));
        }
        // Update password jika diisi
        if (passwordController.text.isNotEmpty) {
          await supabase.auth.updateUser(UserAttributes(password: passwordController.text));
        }
        Get.find<ProfileController>().fetchUserData();
        Get.back();
        Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
