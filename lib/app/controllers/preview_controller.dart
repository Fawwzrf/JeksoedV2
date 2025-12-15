import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewNavigationController extends GetxController {
  // Mock data untuk preview
  final mockUsers = <String, Map<String, dynamic>>{
    'passenger@jeksoed.com': {
      'role': 'passenger',
      'name': 'Ahmad Penumpang',
      'nim': '2001001001',
    },
    'driver@jeksoed.com': {
      'role': 'driver',
      'name': 'Budi Driver',
      'nim': '2001001002',
    },
  };

  // User state
  final isLoggedIn = false.obs;
  final currentUser = Rx<Map<String, dynamic>?>(null);

  void login(String email, String password) {
    if (mockUsers.containsKey(email.toLowerCase())) {
      currentUser.value = mockUsers[email.toLowerCase()];
      isLoggedIn.value = true;
      Get.snackbar(
        "Success",
        "Login berhasil sebagai ${currentUser.value!['role']}",
      );
    } else {
      Get.snackbar("Error", "Email tidak terdaftar");
    }
  }

  void logout() {
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.snackbar("Info", "Logout berhasil");
  }

  void register(String email, String name, String role) {
    mockUsers[email.toLowerCase()] = {
      'role': role,
      'name': name,
      'nim': '2001001${mockUsers.length + 1}',
    };

    currentUser.value = mockUsers[email.toLowerCase()];
    isLoggedIn.value = true;
    Get.snackbar("Success", "Registrasi berhasil sebagai $role");
  }

  // Mock trip data
  final mockTrips = [
    {
      'id': '1',
      'from': 'Fakultas Teknik',
      'to': 'Asrama Putra',
      'date': '2024-12-03',
      'fare': 15000,
      'status': 'completed',
    },
    {
      'id': '2',
      'from': 'Gedung Rektorat',
      'to': 'Perpustakaan',
      'date': '2024-12-02',
      'fare': 10000,
      'status': 'completed',
    },
  ];

  // Mock driver requests
  final mockDriverRequests = [
    {
      'id': '1',
      'passengerName': 'Sarah Mahasiswa',
      'pickup': 'Fakultas MIPA',
      'destination': 'Asrama Putri',
      'distance': '2.3 km',
      'fare': 12000,
      'estimatedTime': '8 menit',
    },
    {
      'id': '2',
      'passengerName': 'Andi Teknik',
      'pickup': 'Lab Komputer',
      'destination': 'Kantin Pusat',
      'distance': '1.1 km',
      'fare': 8000,
      'estimatedTime': '5 menit',
    },
  ];
}

class PreviewHelper {
  // static void showPreviewInfo() {
  //   Get.dialog(
  //     AlertDialog(
  //       title: Text("🎭 Mode Preview"),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Aplikasi dalam mode preview. Gunakan data berikut:"),
  //           SizedBox(height: 16),
  //           Text(
  //             "📧 Login Penumpang:",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           Text("Email: passenger@jeksoed.com"),
  //           Text("Password: apapun"),
  //           SizedBox(height: 12),
  //           Text(
  //             "🚗 Login Driver:",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           Text("Email: driver@jeksoed.com"),
  //           Text("Password: apapun"),
  //           SizedBox(height: 12),
  //           Text(
  //             "✨ Fitur yang bisa ditest:",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           Text("• Login & Register"),
  //           Text("• Navigasi antar halaman"),
  //           Text("• UI semua komponen"),
  //           Text("• Mock data trip & activity"),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Get.back(), child: Text("Mengerti")),
  //       ],
  //     ),
  //   );
  // }
}
