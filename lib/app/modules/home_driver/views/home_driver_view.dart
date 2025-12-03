import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/home_driver_controller.dart';

class HomeDriverView extends GetView<HomeDriverController> {
  const HomeDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Maps
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.driverLocation.value,
                zoom: 15,
              ),
              onMapCreated: controller.onMapCreated,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),

          // 2. Status Indicator (Top Center)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.isOnline.value
                        ? const Color(0xFFFFC107)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    controller.isOnline.value ? "Kamu Online" : "Kamu Offline",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: controller.isOnline.value
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Driver Info Card (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200, // Sesuaikan tinggi
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: const Text(
                      "Nama Driver",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("R 1234 AB"),
                    trailing: Obx(
                      () => GestureDetector(
                        onTap: controller.toggleStatus,
                        child: CircleAvatar(
                          backgroundColor: controller.isOnline.value
                              ? Colors.green
                              : Colors.grey[300],
                          child: const Icon(
                            Icons.power_settings_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Statistik (Balance, Rating, Orderan)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF272343),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _StatItem(label: "Balance", value: "Rp 0"),
                          _StatItem(label: "Rating", value: "5.0"),
                          _StatItem(label: "Orderan", value: "0"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
