import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // For production use
// import 'package:cloud_firestore/cloud_firestore.dart'; // For production use
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar("Error", "Email dan password harus diisi!");
      return;
    }

    try {
      isLoading.value = true;

      // Untuk preview, simulasi login berhasil
      await Future.delayed(Duration(milliseconds: 1500));

      // Mock login - cek email untuk role
      if (emailC.text.toLowerCase().contains('driver') ||
          emailC.text.toLowerCase().contains('sopir')) {
        Get.offAllNamed(Routes.driverMain);
        Get.snackbar("Success", "Login sebagai Driver berhasil!");
      } else {
        Get.offAllNamed(Routes.passengerMain);
        Get.snackbar("Success", "Login sebagai Penumpang berhasil!");
      }

      /* Original Firebase login - uncomment for production
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailC.text.trim(),
            password: passwordC.text,
          );

      if (userCred.user != null) {
        // Ambil data user dari Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userCred.user!.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          String role = userData['role'] ?? 'passenger';

          // Navigate berdasarkan role
          if (role == 'driver') {
            Get.offAllNamed(Routes.driverMain);
          } else {
            Get.offAllNamed(Routes.passengerMain);
          }
        } else {
          Get.snackbar("Error", "Data user tidak ditemukan!");
        }      }
      */
    } catch (e) {
      // Simulasi error handling untuk preview
      Get.snackbar("Error", "Login gagal! Coba periksa email dan password.");

      /* Original Firebase error handling - uncomment for production
    } on FirebaseAuthException catch (e) {
      String message = "Login gagal!";
      switch (e.code) {
        case 'user-not-found':
          message = "Email tidak terdaftar!";
          break;
        case 'wrong-password':
          message = "Password salah!";
          break;
        case 'invalid-email':
          message = "Format email tidak valid!";
          break;
        case 'user-disabled':
          message = "Akun telah dinonaktifkan!";
          break;
        case 'too-many-requests':
          message = "Terlalu banyak percobaan! Coba lagi nanti.";
          break;
        default:
          message = e.message ?? "Terjadi kesalahan!";
      }
      Get.snackbar("Error", message);
    } catch (e) {
      print("Error during login: $e");
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
      */
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.registerPassenger);
  }

  void goToRoleSelection() {
    Get.toNamed(Routes.roleSelection);
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.forgotPassword);
  }

  void goToTerms() {
    Get.toNamed(Routes.tnc);
  }

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}
