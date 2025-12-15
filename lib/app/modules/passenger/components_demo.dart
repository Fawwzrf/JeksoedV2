import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import 'components/components.dart';

/// Demo screen untuk menampilkan semua komponen yang telah dikonversi dari Kotlin ke Dart
class ComponentsDemo extends StatefulWidget {
  const ComponentsDemo({super.key});

  @override
  State<ComponentsDemo> createState() => _ComponentsDemoState();
}

class _ComponentsDemoState extends State<ComponentsDemo> {
  OrderUiState _orderState = OrderUiState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TopHeader Component Demo
              _buildSection(
                title: "1. TopHeader Component",
                child: TopHeader(
                  name: "Sobat JekSoed",
                  hasNotification: true,
                  onNotificationClick: () {
                    Get.snackbar(
                      "Notifikasi",
                      "Anda memiliki notifikasi baru!",
                    );
                  },
                ),
              ),

              // 2. CategoryGrid Component Demo
              _buildSection(
                title: "2. CategoryGrid Component",
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CategoryGrid(
                    onCategoryClick: (categoryName) {
                      Get.snackbar("Category", "Anda memilih: $categoryName");
                    },
                  ),
                ),
              ),

              // 3. RecommendationSection Component Demo
              _buildSection(
                title: "3. RecommendationSection Component",
                child: const RecommendationSection(),
              ),

              // 4. HistorySection Component Demo
              _buildSection(
                title: "4. HistorySection Component",
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RecentHistoryList(
                    history: [
                      RideHistoryItem(
                        destinationName: "RITA SuperMall",
                        destinationAddress:
                            "Jl. Jend. Sudirman No.296, Purwokerto",
                      ),
                      RideHistoryItem(
                        destinationName: "Universitas Jenderal Soedirman",
                        destinationAddress:
                            "Jl. Profesor DR. HR Boenyamin No.708, Grendeng",
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Order Stages Demo
              _buildSection(
                title: "5. Order Stages Components",
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Stage Selector
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStageButton("Search", OrderStage.searching),
                            _buildStageButton(
                              "Pickup",
                              OrderStage.pickupConfirm,
                            ),
                            _buildStageButton("Route", OrderStage.routeConfirm),
                            _buildStageButton(
                              "Finding",
                              OrderStage.findingDriver,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Demo content
                      SizedBox(
                        height: 300,
                        child: OrderSheetContent(
                          uiState: _orderState,
                          onDestinationQueryChanged: (query) {
                            setState(() {
                              _orderState = _orderState.copyWith(
                                destinationQuery: query,
                              );
                            });
                          },
                          onPredictionSelected: (prediction) {
                            Get.snackbar("Prediction", "Selected: $prediction");
                          },
                          onSavedPlaceSelected: (place) {
                            Get.snackbar(
                              "Saved Place",
                              "Selected: ${place.title}",
                            );
                          },
                          onTextFieldFocus: () {
                            debugPrint("TextField focused");
                          },
                          onLocationClick: () {
                            Get.snackbar(
                              "Location",
                              "Current location clicked",
                            );
                          },
                          onProceedClick: () {
                            setState(() {
                              _orderState = _orderState.copyWith(
                                stage: OrderStage.routeConfirm,
                              );
                            });
                          },
                          onBackClick: () {
                            setState(() {
                              _orderState = _orderState.copyWith(
                                stage: OrderStage.searching,
                              );
                            });
                          },
                          onCreateOrderClick: () {
                            setState(() {
                              _orderState = _orderState.copyWith(
                                stage: OrderStage.findingDriver,
                              );
                            });
                          },
                          onCancelFindingDriver: () {
                            setState(() {
                              _orderState = _orderState.copyWith(
                                stage: OrderStage.searching,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.back(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        label: const Text("Kembali"),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStageButton(String label, OrderStage stage) {
    final isSelected = _orderState.stage == stage;
    return GestureDetector(
      onTap: () {
        setState(() {
          _orderState = _orderState.copyWith(
            stage: stage,
            destinationQuery: stage == OrderStage.searching
                ? ""
                : "RITA SuperMall",
            routeInfo: stage == OrderStage.routeConfirm
                ? RouteInfo(
                    price: "Rp 15.000",
                    distance: "5.2 km",
                    duration: "12 min",
                  )
                : null,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
