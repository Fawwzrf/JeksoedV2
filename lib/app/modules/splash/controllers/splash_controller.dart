import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';  // For production use
// import 'package:cloud_firestore/cloud_firestore.dart'; // For production use
// import 'package:firebase_messaging/firebase_messaging.dart'; // For production use
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // For production use
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // For production use

  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Jalankan penundaan dan logika navigasi secara bersamaan
    await Future.wait([_delayMinimum(), _handleNavigation()]);
  }

  Future<void> _delayMinimum() async {
    // Penundaan minimum agar logo terlihat
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  Future<void> _handleNavigation() async {
    // Untuk preview, langsung arahkan ke CTA tanpa cek auth
    Get.offNamed(Routes.cta);
    return;

    /* Original auth logic - uncomment for production
    User? user = _auth.currentUser;

    if (user == null) {
      // Jika belum login, arahkan ke CTA      Get.offAllNamed(Routes.cta);
    } else {
      try {
        // Ambil data peran dari Firestore
        String uid = user.uid;
        DocumentSnapshot document = await _firestore
            .collection("users")
            .doc(uid)
            .get();
        String? userRole = document.data() != null
            ? (document.data() as Map<String, dynamic>)['role'] as String?
            : null;

        // Update FCM token di latar belakang (tidak perlu ditunggu)
        _updateFcmTokenInBackground(uid);

        String destination;
        switch (userRole) {
          case "penumpang":
            destination = Routes.passengerMain; // Updated to main navigation
            break;
          case "driver":
            destination = Routes.driverMain; // Updated to main navigation
            break;
          default:
            destination = Routes.login;
            break;
        }

        Get.offAllNamed(destination);
      } catch (e) {
        // Jika gagal mengambil data, arahkan ke Login
        // print("Gagal mengambil data user: $e"); // Removed print for production
        Get.offAllNamed(Routes.login);
      }
    }
    */
  }

  /* FCM token update method - for production use
  void _updateFcmTokenInBackground(String uid) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      await _firestore.collection("users").doc(uid).update({
        "fcmToken": token,
      });
    } catch (e) {
      // print("Gagal update FCM token: $e"); // Removed print for production
      // Silently handle FCM token update failure
    }
  }
  */
}
