import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:io';
import '../../../app/routes/app_pages.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import '../models/user.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  // Client supabase
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  // Current user
  final Rx<User?> _currentUser = Rx<User?>(null);
  User? get currentUser => _currentUser.value;

  // Authentication state
  final RxBool _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _recoverSession();
  }

  // Cek sesi yang tersimpan
  Future<void> _recoverSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id);
    }
  }

  // Load user profile dari tabel 'users' di database
  Future<void> _loadUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();

      _currentUser.value = User.fromJson(data);
      _isLoggedIn.value = true;
    } catch (e) {
      print("Error loading profile: $e");
      // Jika user ada di Auth tapi tidak ada di tabel users, logout
      await logout();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } on sb.AuthException catch (e) {
      Get.snackbar('Login Gagal', e.message);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register new user
  Future<bool> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      // 1. Sign Up Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) return false;

      // 2. Insert to 'users' table
      final userData = {
        'id': response.user!.id,
        'name': name,
        'email': email,
        'phone': phone,
        'user_type': 'passenger',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('users').insert(userData);

      return true;
    } on sb.AuthException catch (e) {
      Get.snackbar('Registration Failed', e.message);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register new driver with comprehensive data
  Future<bool> registerDriver(
    Map<String, dynamic> userData,
    Map<String, dynamic> driverData,
  ) async {
    try {
      _isLoading.value = true;

      final authResponse = await _supabase.auth.signUp(
        email: userData['email'],
        password: userData['password'],
        data: {'name': userData['name'], 'phone': userData['phone']},
      );

      if (authResponse.user == null) throw "Gagal membuat akun.";
      final userId = authResponse.user!.id;

      String? ktpUrl = await _uploadFile(userId, 'ktp', driverData['ktp_path']);
      String? simUrl = await _uploadFile(userId, 'sim', driverData['sim_path']);
      String? vehicleUrl = await _uploadFile(
        userId,
        'vehicle',
        driverData['vehicle_path'],
      );

      final driverProfile = {
        'id': userId,
        'name': userData['name'],
        'email': userData['email'],
        'phone': userData['phone'],
        'user_type': 'driver',
        'license_number': driverData['licenseNumber'],
        'vehicle_type': driverData['vehicleType'],
        'vehicle_plate': driverData['vehiclePlate'],
        'ktp_url': ktpUrl,
        'sim_url': simUrl,
        'vehicle_photo_url': vehicleUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('drivers').insert(driverProfile);

      Get.snackbar(
        'Pendaftaran Berhasil',
        'Data Anda telah dikirim untuk diverifikasi.',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendaftar driver: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Upload file to Supabase Storage
  Future<String?> _uploadFile(
    String userId,
    String category,
    String? filePath,
  ) async {
    if (filePath == null || filePath.isEmpty) return null;
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName =
          '$userId/$category.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('driver_documents').upload(fileName, file);
      return _supabase.storage.from('driver_documents').getPublicUrl(fileName);
    } catch (e) {
      print("Gagal upload $category: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      await _supabase.auth.signOut();

      _currentUser.value = null;
      _isLoggedIn.value = false;

      // Navigate to splash screen
      Get.offAllNamed('/splash');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      Map<String, dynamic> updates = {
        'name': name,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Jika ada foto baru yang diupload
      if (profileImageUrl != null && !profileImageUrl.startsWith('http')) {
        final file = File(profileImageUrl);
        final fileExt = profileImageUrl.split('.').last;
        final fileName =
            '$userId/avatar.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Upload ke bucket 'avatars'
        await _supabase.storage
            .from('avatars')
            .upload(
              fileName,
              file,
              fileOptions: const sb.FileOptions(upsert: true),
            );

        final publicUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);
        updates['profile_image_url'] = publicUrl;
      }

      await _supabase.auth.updateUser(
        sb.UserAttributes(data: {'name': name, 'phone': phone}),
      );

      // Update Tabel Database
      await _supabase.from('users').update(updates).eq('id', userId);

      // Refresh data lokal
      await _loadUserProfile(userId);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal update profil: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      // Supabase langsung update password user yang sedang login
      await _supabase.auth.updateUser(sb.UserAttributes(password: newPassword));

      Get.snackbar('Sukses', 'Password berhasil diubah');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah password: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.jeksoed://login-callback',
      );

      Get.snackbar(
        'Email Terkirim',
        'Cek email Anda untuk link reset password.',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim reset password: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
