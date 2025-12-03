// filepath: lib/app/modules/shared/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var uiState = ProfileUiState().obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final document = await _firestore
            .collection("users")
            .doc(user.uid)
            .get();

        if (document.exists) {
          final data = document.data() as Map<String, dynamic>;

          uiState.value = uiState.value.copyWith(
            name: data['nama'] ?? 'Nama tidak ditemukan',
            email: user.email ?? 'Email tidak ditemukan',
            photoUrl: data['photoUrl'] ?? '',
            role: data['role'] ?? 'passenger',
            isLoading: false,
          );
        } else {
          uiState.value = uiState.value.copyWith(
            name: 'Data tidak ditemukan',
            email: user.email ?? 'Email tidak ditemukan',
            photoUrl: '',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      uiState.value = uiState.value.copyWith(
        name: 'Gagal memuat data',
        email: 'Gagal memuat data',
        photoUrl: '',
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
      await _auth.signOut();
      onDismissLogoutDialog();
      Get.offAllNamed('/cta');
    } catch (e) {
      print('Error during logout: $e');
      Get.snackbar('Error', 'Gagal logout: $e');
      onDismissLogoutDialog();
    }
  }

  Future<void> confirmDeleteAccount() async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;

      if (uid != null) {
        // 1. Delete data from Firestore
        await _firestore.collection("users").doc(uid).delete();

        // 2. Delete user from Auth
        await user!.delete();

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
