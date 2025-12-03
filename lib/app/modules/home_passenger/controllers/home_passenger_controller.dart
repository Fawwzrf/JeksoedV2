import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePassengerController extends GetxController {
  var userName = "Sobat Jeksoed".obs;
  var isLoading = true.obs;
  var hasNotification = true.obs;
  var recentTrips = <Map<String, String>>[].obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> refreshData() async {
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    String? uid = _auth.currentUser?.uid;
    try {
      var doc = await _firestore.collection("users").doc(uid).get();
      if (doc.exists) {
        String fullName = doc.get("nama") ?? "Sobat Jeksoed";
        userName.value = fullName.split(" ").first;
      }
      // Fetch history trips
      await fetchRecentTrips();
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
    }

  Future<void> fetchRecentTrips() async {
    try {
      String? uid = _auth.currentUser?.uid;
      var query = await _firestore
          .collection("ride_requests")
          .where("passengerId", isEqualTo: uid)
          .where("status", isEqualTo: "completed")
          .orderBy("createdAt", descending: true)
          .limit(5)
          .get();

      recentTrips.value = query.docs.map((doc) {
        var data = doc.data();
        return {
          'destination': (data['destinationName'] ?? 'Tujuan tidak diketahui')
              .toString(),
          'address': (data['destinationAddress'] ?? 'Alamat tidak tersedia')
              .toString(),
          'date': data['createdAt'] != null
              ? _formatDate(data['createdAt'].toDate())
              : '',
        };
      }).toList();
        } catch (e) {
      print("Error fetching recent trips: $e");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}";
  }

  void onCategoryClick(String category) {
    if (category == "JekMotor") {
      Get.toNamed('/create-order');
    } else {
      Get.defaultDialog(
        title: "Dalam Pengembangan",
        middleText: "Fitur ini masih dalam tahap pengembangan.",
        textConfirm: "OK",
        confirmTextColor: Get.theme.primaryColor,
        onConfirm: () => Get.back(),
      );
    }
  }

  void onSearchClick() {
    Get.toNamed('/create-order');
  }

  void onNotificationClick() {
    hasNotification.value = false;
    Get.defaultDialog(
      title: "Notifikasi",
      middleText: "Belum ada notifikasi baru.",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }

  void onHistoryItemClick(Map<String, String> trip) {
    Get.defaultDialog(
      title: "Detail Perjalanan",
      middleText: "Tujuan: ${trip['destination']}\nAlamat: ${trip['address']}",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }
}
