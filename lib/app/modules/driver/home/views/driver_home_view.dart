import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/driver_home_controller.dart';
import '../components/components.dart';

class DriverHomeView extends GetView<DriverHomeController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps Background
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.driverLocation.value,
                zoom: 15,
              ),
              onMapCreated: controller.onMapCreated,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: controller.markers.toSet(),
            ),
          ),

          // Status Indicator (Top Center)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Obx(
              () => StatusIndicator(isOnline: controller.isOnline.value),
            ),
          ),

          // Notification Button (Top Right)
          Positioned(
            top: 50,
            right: 16,
            child: NotificationButton(
              onNotificationClick: controller.onNotificationClick,
            ),
          ),

          // Driver Info Card (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(
              () => DriverInfoCard(
                profile: controller.driverProfile.value,
                isOnline: controller.isOnline.value,
                isLoadingProfile: controller.isLoadingProfile.value,
                onToggleStatus: controller.toggleOnlineStatus,
              ),
            ),
          ),

          // Ride Request Popup (Overlay)
          Obx(
            () => controller.popupRideRequest.value != null
                ? Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: RideRequestPopup(
                      rideRequest: controller.popupRideRequest.value!,
                      onAccept: () => controller.acceptRideRequest(
                        controller.popupRideRequest.value!,
                      ),
                      onReject: () => controller.rejectRideRequest(
                        controller.popupRideRequest.value!.id,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Offline Confirmation Dialog
          Obx(
            () => controller.showOfflineDialog.value
                ? Container(
                    color: Colors.black54,
                    child: Center(
                      child: OfflineConfirmationDialog(
                        onDismiss: controller.dismissOfflineDialog,
                        onConfirm: controller.confirmGoOffline,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
