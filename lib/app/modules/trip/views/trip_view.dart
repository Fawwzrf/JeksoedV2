// filepath: lib/app/modules/trip/views/trip_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/trip_controller.dart';
import '../components/trip_driver_bottom_sheet.dart';
import '../components/trip_passenger_sheet.dart';
import '../components/payment_confirmation_card.dart';
import '../../../../utils/app_colors.dart';

class TripView extends GetView<TripController> {
  const TripView({super.key});

  @override
  Widget build(BuildContext context) {
    // Start location updates if driver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.uiState.value.isDriver) {
        controller.startLocationUpdates();
      }
    });

    return Obx(() {
      final uiState = controller.uiState.value;
      return TripScreenLayout(
        uiState: uiState,
        onUpdateStatus: controller.updateTripStatus,
        onCancelTrip: controller.cancelTrip,
        onFinishTrip: controller.confirmPaymentAndFinishTrip,
        onChatClick: (_) => controller.navigateToChat(),
        onBackClick: () => Get.back(),
      );
    });
  }
}

class TripScreenLayout extends StatefulWidget {
  final TripUiState uiState;
  final Function(String) onUpdateStatus;
  final VoidCallback onCancelTrip;
  final VoidCallback onFinishTrip;
  final Function(String) onChatClick;
  final VoidCallback onBackClick;

  const TripScreenLayout({
    super.key,
    required this.uiState,
    required this.onUpdateStatus,
    required this.onCancelTrip,
    required this.onFinishTrip,
    required this.onChatClick,
    required this.onBackClick,
  });

  @override
  State<TripScreenLayout> createState() => _TripScreenLayoutState();
}

class _TripScreenLayoutState extends State<TripScreenLayout> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void didUpdateWidget(TripScreenLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uiState != oldWidget.uiState) {
      _updateMapElements();
      _updateCameraPosition();
    }
  }

  void _updateMapElements() {
    final request = widget.uiState.rideRequest;
    if (request == null) return;

    setState(() {
      markers.clear();
      polylines.clear();

      // Add pickup marker
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: request.pickupLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: request.pickupAddress,
          ),
        ),
      );

      // Add destination marker
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: request.destinationLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: request.destinationAddress,
          ),
        ),
      );

      // Add driver marker if available
      if (request.driverCurrentLocation != null) {
        final driverPos = LatLng(
          request.driverCurrentLocation!['latitude'] ?? 0.0,
          request.driverCurrentLocation!['longitude'] ?? 0.0,
        );
        markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: driverPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Driver Location'),
          ),
        );
      }

      // Add polyline if available
      if (widget.uiState.dynamicPolylinePoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: widget.uiState.dynamicPolylinePoints,
            color: AppColors.primaryGreen,
            width: 5,
            patterns: [],
          ),
        );
      }
    });
  }

  void _updateCameraPosition() {
    final request = widget.uiState.rideRequest;
    if (request == null || mapController == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToShowAllMarkers();
    });
  }

  void _fitMapToShowAllMarkers() {
    if (markers.isEmpty || mapController == null) return;

    final bounds = _calculateBounds(markers.map((m) => m.position).toList());
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 150.0));
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      minLat = math.min(minLat, pos.latitude);
      maxLat = math.max(maxLat, pos.latitude);
      minLng = math.min(minLng, pos.longitude);
      maxLng = math.max(maxLng, pos.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.uiState.rideRequest;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-7.4298, 109.2481),
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _updateMapElements();
              _updateCameraPosition();
            },
            myLocationEnabled: widget.uiState.isDriver,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackClick,
                color: Colors.black,
              ),
            ),
          ),

          // Bottom Sheet (hide when payment confirmation is showing)
          if (!(request?.status == 'completed' && widget.uiState.isDriver))
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomSheet()),

          if (request?.status == 'completed' && widget.uiState.isDriver)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: PaymentConfirmationCard(
                totalPayment: 'Rp${request?.fare ?? 0}',
                onConfirmClick: widget.onFinishTrip,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (widget.uiState.isDriver) {
      return TripDriverBottomSheet(
        uiState: widget.uiState,
        onUpdateStatus: widget.onUpdateStatus,
        onCancelTrip: widget.onCancelTrip,
        onChatClick: () =>
            widget.onChatClick(widget.uiState.rideRequest?.id ?? ''),
      );
    } else {
      return TripPassengerSheet(
        uiState: widget.uiState,
        onCancelTrip: widget.onCancelTrip,
        onChatClick: () =>
            widget.onChatClick(widget.uiState.rideRequest?.id ?? ''),
      );
    }
  }
}
