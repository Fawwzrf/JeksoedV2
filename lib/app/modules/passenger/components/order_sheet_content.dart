import 'package:flutter/material.dart';
import 'search_stage.dart';
import 'pickup_confirm_stage.dart';
import 'route_confirm_stage.dart';
import 'finding_driver_stage.dart';

enum OrderStage { searching, pickupConfirm, routeConfirm, findingDriver }

class OrderUiState {
  final OrderStage stage;
  final String pickupQuery;
  final String pickupAddress;
  final String destinationQuery;
  final String destinationAddress;
  final List<dynamic> predictions;
  final List<SavedPlace> savedPlaces;
  final bool isSearchingPickup;
  final bool isSearchingDestination;
  final RouteInfo? routeInfo;
  final bool isRouteLoading;

  OrderUiState({
    this.stage = OrderStage.searching,
    this.pickupQuery = "",
    this.pickupAddress = "",
    this.destinationQuery = "",
    this.destinationAddress = "",
    this.predictions = const [],
    this.savedPlaces = const [],
    this.isSearchingPickup = false,
    this.isSearchingDestination = false,
    this.routeInfo,
    this.isRouteLoading = false,
  });

  OrderUiState copyWith({
    OrderStage? stage,
    String? pickupQuery,
    String? pickupAddress,
    String? destinationQuery,
    String? destinationAddress,
    List<dynamic>? predictions,
    List<SavedPlace>? savedPlaces,
    bool? isSearchingPickup,
    bool? isSearchingDestination,
    RouteInfo? routeInfo,
    bool? isRouteLoading,
  }) {
    return OrderUiState(
      stage: stage ?? this.stage,
      pickupQuery: pickupQuery ?? this.pickupQuery,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      predictions: predictions ?? this.predictions,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      isSearchingPickup: isSearchingPickup ?? this.isSearchingPickup,
      isSearchingDestination:
          isSearchingDestination ?? this.isSearchingDestination,
      routeInfo: routeInfo ?? this.routeInfo,
      isRouteLoading: isRouteLoading ?? this.isRouteLoading,
    );
  }
}

class OrderSheetContent extends StatelessWidget {
  final OrderUiState uiState;
  final Function(String) onDestinationQueryChanged;
  final Function(dynamic) onPredictionSelected;
  final Function(SavedPlace) onSavedPlaceSelected;
  final VoidCallback onTextFieldFocus;
  final VoidCallback onLocationClick;
  final VoidCallback onProceedClick;
  final VoidCallback onBackClick;
  final VoidCallback onCreateOrderClick;
  final VoidCallback onCancelFindingDriver;

  const OrderSheetContent({
    super.key,
    required this.uiState,
    required this.onDestinationQueryChanged,
    required this.onPredictionSelected,
    required this.onSavedPlaceSelected,
    required this.onTextFieldFocus,
    required this.onLocationClick,
    required this.onProceedClick,
    required this.onBackClick,
    required this.onCreateOrderClick,
    required this.onCancelFindingDriver,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content based on stage
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (uiState.stage) {
      case OrderStage.searching:
        return SearchStage(
          pickupQuery: uiState.pickupQuery,
          destinationQuery: uiState.destinationQuery,
          predictions: uiState.predictions,
          savedPlaces: uiState.savedPlaces,
          onDestinationQueryChanged: onDestinationQueryChanged,
          onPredictionSelected: onPredictionSelected,
          onSavedPlaceSelected: onSavedPlaceSelected,
          onTextFieldFocus: onTextFieldFocus,
          onLocationClick: onLocationClick,
        );

      case OrderStage.pickupConfirm:
        return PickupConfirmStage(
          destinationQuery: uiState.destinationQuery,
          destinationAddress: uiState.destinationAddress,
          isRouteLoading: uiState.isRouteLoading,
          onProceedClick: onProceedClick,
          onBackClick: onBackClick,
        );

      case OrderStage.routeConfirm:
        return RouteConfirmStage(
          routeInfo: uiState.routeInfo,
          onCreateOrderClick: onCreateOrderClick,
        );

      case OrderStage.findingDriver:
        return FindingDriverStage(onCancelClick: onCancelFindingDriver);
    }
  }
}
