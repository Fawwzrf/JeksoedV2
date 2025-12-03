import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // For production use
// import 'package:cloud_firestore/cloud_firestore.dart'; // For production use
import '../../../../routes/app_pages.dart';

class RegisterPassengerController extends GetxController {
  final nameC = TextEditingController();
  final nimC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passwordC = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void register() async {
    if (nameC.text.isEmpty ||
        nimC.text.isEmpty ||
        emailC.text.isEmpty ||
        phoneC.text.isEmpty ||
        passwordC.text.isEmpty) {
      Get.snackbar("Error", "Semua field harus diisi!");
      return;
    }
    try {
      isLoading.value = true;

      // Simulasi registrasi untuk preview
      await Future.delayed(Duration(milliseconds: 1500));

      Get.snackbar(
        "Success",
        "Registrasi berhasil! Selamat datang ${nameC.text}",
      );
      Get.offAllNamed(Routes.passengerMain);

      /* Original Firebase registration - uncomment for production
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailC.text,
            password: passwordC.text,
          );

      String uid = userCred.user!.uid;

      // Simpan data ke Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "nama": nameC.text,
        "nim": nimC.text,
        "email": emailC.text,
        "nomorHp": phoneC.text,
        "role": "penumpang",
        "createdAt": FieldValue.serverTimestamp(),
        "balance": 0,
        "totalRating": 0,
        "ratingCount": 0,
      });

      Get.snackbar("Sukses", "Registrasi Berhasil!");
      Get.offAllNamed(Routes.passengerMain);
      */
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    nimC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}
