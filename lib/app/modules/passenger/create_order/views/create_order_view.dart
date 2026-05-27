// filepath: lib/app/modules/passenger/create_order/views/create_order_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_order_controller.dart';
import '../../../../../utils/app_colors.dart';

class CreateOrderView extends GetView<CreateOrderController> {
  const CreateOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          switch (controller.currentStage.value) {
            case OrderStage.search:
              return _SearchStage(controller: controller);
            case OrderStage.pickupConfirm:
              return _PickupConfirmStage(controller: controller);
            case OrderStage.routeConfirm:
              return _RouteConfirmStage(controller: controller);
            case OrderStage.findingDriver:
              return _FindingDriverStage(controller: controller);
          }
        }),
      ),
    );
  }
}

// --- SEARCH STAGE ---
class _SearchStage extends StatelessWidget {
  final CreateOrderController controller;
  const _SearchStage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Kemana hari ini?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Location inputs
                Container(
                  padding: const EdgeInsets.all(20),
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
                      _LocationInput(
                        icon: Icons.radio_button_checked,
                        iconColor: AppColors.success,
                        label: 'Dari',
                        hint: 'Lokasi penjemputan',
                        controller: controller.pickupController,
                        onTap: () => controller.showLocationPicker(true),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: AppColors.border)),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: GestureDetector(
                              onTap: controller.swapLocations,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(Icons.swap_vert, size: 16, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _LocationInput(
                        icon: Icons.location_on,
                        iconColor: AppColors.error,
                        label: 'Ke',
                        hint: 'Lokasi tujuan',
                        controller: controller.destinationController,
                        onTap: () => controller.showLocationPicker(false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lokasi Terkini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...controller.recentLocations.map((location) => _RecentLocationItem(location: location, onTap: () => controller.selectRecentLocation(location))),
              ],
            ),
          ),
        ),
        // Continue button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Obx(() {
            final canContinue = controller.isFormValid.value;
            return _ActionButton(
              text: 'Lanjutkan',
              onPressed: canContinue ? controller.nextStage : null,
              isEnabled: canContinue,
            );
          }),
        ),
      ],
    );
  }
}

// --- Location Input Widget ---
class _LocationInput extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _LocationInput({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: false,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Recent Location Item Widget ---
class _RecentLocationItem extends StatelessWidget {
  final String location;
  final VoidCallback onTap;
  const _RecentLocationItem({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history, color: AppColors.textSecondary),
      title: Text(location, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}

// --- Action Button Widget ---
class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  const _ActionButton({required this.text, required this.onPressed, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : AppColors.textGrey.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- Dummy/Fallback for Controller Properties/Methods ---
extension _CreateOrderControllerExt on CreateOrderController {
  List<String> get recentLocations => [
    'Universitas Jenderal Soedirman',
    'Terminal Purwokerto',
    'Plaza Asia',
  ];
  void showLocationPicker(bool isPickup) {}
  void swapLocations() {}
  void selectRecentLocation(String location) {}
}

// --- Pickup Confirm Stage Widget ---
class _PickupConfirmStage extends StatelessWidget {
  final CreateOrderController controller;
  const _PickupConfirmStage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Pickup Confirm Stage (implementasi detail menyusul)'));
  }
}

// --- Route Confirm Stage Widget ---
class _RouteConfirmStage extends StatelessWidget {
  final CreateOrderController controller;
  const _RouteConfirmStage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Route Confirm Stage (implementasi detail menyusul)'));
  }
}

// --- Finding Driver Stage Widget ---
class _FindingDriverStage extends StatelessWidget {
  final CreateOrderController controller;
  const _FindingDriverStage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Finding Driver Stage (implementasi detail menyusul)'));
  }
}
