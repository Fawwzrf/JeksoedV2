import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/create_order_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/marker_utils.dart';
import '../../components/components.dart';

class CreateOrderView extends GetView<CreateOrderController> {
  const CreateOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        final stage = controller.currentStage.value;
        
        // Calculate sheet peek height based on stage
        final sheetPeekHeight = _getSheetPeekHeight(context, stage);
        
        return Stack(
          children: [
            // Google Map Background
            _buildGoogleMap(),
            
            if (stage == OrderStage.routeConfirm ||
                stage == OrderStage.findingDriver)
              Obx(() => TopRouteInfoBar(
                pickup: controller.pickupQuery.value,
                destination: controller.destinationQuery.value,
              )),
            
            // Back Button
            _buildBackButton(context, stage, sheetPeekHeight),
            
            // Bottom Sheet with Content
            _buildBottomSheet(context, sheetPeekHeight),
          ],
        );
      }),
    );
  }

  Widget _buildGoogleMap() {
    return Obx(() {
      final stage = controller.currentStage.value;
      final isBlurred = stage == OrderStage.findingDriver;
      
      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: controller.cameraPosition.value,
            onMapCreated: controller.onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
          ),
          // Blur effect when finding driver
          if (isBlurred)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
        ],
      );
    });
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    
    // Pickup Marker (with custom user photo marker)
    if (controller.pickupLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: controller.pickupLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: const InfoWindow(title: 'Lokasi Jemput'),
        ),
      );
    }
    
    // Destination Marker
    if (controller.destLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: controller.destLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Tujuan'),
        ),
      );
    }
    
    // Driver Markers
    for (int i = 0; i < controller.driverLocations.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('driver_$i'),
          position: controller.driverLocations[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      );
    }
    
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};
    
    // Route Polyline (when in route confirm or finding driver stage)
    if (controller.currentStage.value == OrderStage.routeConfirm ||
        controller.currentStage.value == OrderStage.findingDriver) {
      if (controller.pickupLatLng != null && controller.destLatLng != null) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              controller.pickupLatLng!,
              controller.destLatLng!,
            ],
            color: AppColors.primary,
            width: 5,
          ),
        );
      }
    }
    
    return polylines;
  }

  Widget _buildBackButton(BuildContext context, OrderStage stage, double sheetPeekHeight) {
    if (stage == OrderStage.findingDriver) {
      return const SizedBox.shrink(); // No back button when finding driver
    }
    
    final isRouteConfirm = stage == OrderStage.routeConfirm;
    
    return Positioned(
      top: isRouteConfirm ? 170 : 50, // Below TopRouteInfoBar for route confirm
      bottom: null,
      left: 16,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: controller.onBackClick,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, double sheetPeekHeight) {
    return DraggableScrollableSheet(
      initialChildSize: sheetPeekHeight / MediaQuery.of(context).size.height,
      minChildSize: sheetPeekHeight / MediaQuery.of(context).size.height,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Sheet Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildSheetContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetContent() {
    return Obx(() {
      switch (controller.currentStage.value) {
        case OrderStage.search:
          return SearchStage(
            pickupQuery: controller.pickupQuery.value,
            destinationQuery: controller.destinationQuery.value,
            predictions: controller.predictions.toList(),
            savedPlaces: controller.savedPlaces.toList(),
            onPickupQueryChanged: controller.onPickupQueryChanged,
            onDestinationQueryChanged: controller.onDestinationQueryChanged,
            onPredictionSelected: (pred) => controller.onPredictionSelected(pred),
            onSavedPlaceSelected: (place) => controller.onSavedPlaceSelected(place),
            onTextFieldFocus: controller.onTextFieldFocus,
            onLocationClick: controller.onLocationClick,
            clearQuery: controller.clearQuery,
          );
        
        case OrderStage.pickupConfirm:
          return PickupConfirmStage(
            destinationQuery: controller.destinationQuery.value,
            destinationAddress: controller.destinationAddress.value,
            isRouteLoading: controller.isRouteLoading.value,
            onProceedClick: controller.onProceedClick,
            onBackClick: controller.onBackClick,
          );
        
        case OrderStage.routeConfirm:
          return Obx(() => RouteConfirmStage(
            routeInfo: controller.routeInfo,
            onCreateOrderClick: controller.onCreateOrderClick,
          ));
        
        case OrderStage.findingDriver:
          return FindingDriverStage(
            onCancelClick: controller.onCancelClick,
          );
      }
    });
  }

  double _getSheetPeekHeight(BuildContext context, OrderStage stage) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return switch (stage) {
      OrderStage.search => screenHeight * 0.6,
      OrderStage.pickupConfirm => 300,
      OrderStage.routeConfirm => screenHeight * 0.42, 
      OrderStage.findingDriver => 300,
    };
  }
}
