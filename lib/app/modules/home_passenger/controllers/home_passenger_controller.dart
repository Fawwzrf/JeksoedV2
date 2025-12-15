import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePassengerController extends GetxController {
  var userName = "Sobat Jeksoed".obs;
  var isLoading = true.obs;
  var hasNotification = false.obs;
  var recentTrips = <Map<String, String>>[].obs;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> refreshData() async {
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch User Data
      final data = await _supabase
          .from("users")
          .select("name")
          .eq("id", user.id)
          .maybeSingle();

      if (data != null) {
        String fullName = data['name'] ?? "Sobat Jeksoed";
        userName.value = fullName.split(" ").first;
      }

      // Fetch History Trips
      await fetchRecentTrips(user.id);
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecentTrips(String uid) async {
    try {
      final response = await _supabase
          .from("ride_requests")
          .select()
          .eq(
            "passenger_id",
            uid,
          ) // pastikan nama kolom di DB 'passenger_id' atau 'passengerId'
          .eq("status", "completed")
          .order("created_at", ascending: false)
          .limit(5);

      final List<dynamic> dataList = response;

      recentTrips.value = dataList.map((data) {
        return {
          'destination':
              (data['dest_address'] ??
                      data['destinationAddress'] ??
                      'Tujuan tidak diketahui')
                  .toString(),
          'address':
              (data['dest_address'] ??
                      data['destinationAddress'] ??
                      'Alamat tidak tersedia')
                  .toString(),
          'date': data['created_at'] != null
              ? _formatDate(DateTime.parse(data['created_at'].toString()))
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
