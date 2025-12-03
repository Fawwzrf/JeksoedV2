import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeDriverController extends GetxController {
  var isOnline = false.obs;
  var driverLocation = const LatLng(
    -7.4242,
    109.2303,
  ).obs; // Default Purwokerto
  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    // Izin Lokasi harus dihandle di sini (seperti permissionLauncher di Compose)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    driverLocation.value = LatLng(position.latitude, position.longitude);

    // Animate Camera
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(driverLocation.value, 15),
    );
  }

  void toggleStatus() {
    if (isOnline.value) {
      // Tampilkan Dialog Offline
      Get.defaultDialog(
        title: "Kamu mau offline?",
        middleText: "Mau istirahat dulu ya? Kalau offline gak dapet order.",
        textConfirm: "Offline dulu",
        textCancel: "Tetap Online",
        confirmTextColor: Colors.black,
        buttonColor: const Color(0xFFFFC107),
        onConfirm: () {
          isOnline.value = false;
          Get.back();
        },
      );
    } else {
      isOnline.value = true;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
