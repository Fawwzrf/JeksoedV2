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
              return _buildSearchStage();
            case OrderStage.pickupConfirm:
              return _buildPickupConfirmStage();
            case OrderStage.routeConfirm:
              return _buildRouteConfirmStage();
            case OrderStage.findingDriver:
              return _buildFindingDriverStage();
          }
        }),
      ),
    );
  }

  // Stage 1: Search Stage
  Widget _buildSearchStage() {
    return Column(
      children: [
        // Top Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
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
                    color: AppColors.textGrey.withValues(alpha: 0.1),
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
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // From location
                      _buildLocationInput(
                        icon: Icons.radio_button_checked,
                        iconColor: AppColors.success,
                        label: 'Dari',
                        hint: 'Lokasi penjemputan',
                        controller: controller.pickupController,
                        onTap: () =>
                            _showLocationPicker(true), // Fixed: Defined method
                      ),

                      const SizedBox(height: 16),

                      // Divider with swap button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: GestureDetector(
                              onTap: _swapLocations, // Fixed: Defined method
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.swap_vert,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // To location
                      _buildLocationInput(
                        icon: Icons.location_on,
                        iconColor: AppColors.error,
                        label: 'Ke',
                        hint: 'Lokasi tujuan',
                        controller: controller.destinationController,
                        onTap: () =>
                            _showLocationPicker(false), // Fixed: Defined method
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent locations or suggestions
                const Text(
                  'Lokasi Terkini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                ...[
                  'Universitas Jenderal Soedirman',
                  'Terminal Purwokerto',
                  'Plaza Asia',
                ].map((location) => _buildRecentLocationItem(location)),
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
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Obx(() {
            final canContinue = controller.isFormValid.value;

            return _buildActionButton(
              text: 'Lanjutkan',
              onPressed: canContinue ? controller.nextStage : null,
              isEnabled: canContinue,
            );
          }),
        ),
      ],
    );
  }

  // Stage 2: Pickup Confirm Stage
  Widget _buildPickupConfirmStage() {
    return Column(
      children: [
        // Header
        _buildStageHeader('Konfirmasi Penjemputan'),

        // Map placeholder
        Expanded(
          child: Container(
            color: AppColors.surface,
            child: Stack(
              children: [
                // Map container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Map Integration\n(Google Maps)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pickup location card
                Positioned(
                  bottom: 120,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi Penjemputan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.radio_button_checked,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.pickupController.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActionButton(
                text: 'Konfirmasi Lokasi',
                onPressed: controller.nextStage,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                text: 'Ubah Lokasi',
                onPressed: controller.previousStage,
                isSecondary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stage 3: Route Confirm Stage
  Widget _buildRouteConfirmStage() {
    return Column(
      children: [
        // Header
        _buildStageHeader('Pilih Kendaraan'),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.radio_button_checked,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.pickupController.text,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              width: 2,
                              height: 20,
                              color: AppColors.border,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.destinationController.text,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Vehicle selection
                const Text(
                  'Pilih Kendaraan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                  () => Column(
                    children: controller.vehicleTypes.map((vehicle) {
                      final type = vehicle['type'] as String;
                      final name = vehicle['name'] as String;
                      final icon = vehicle['icon'] as IconData;
                      final pricePerKm = vehicle['pricePerKm'] as int;
                      final description = vehicle['description'] as String;
                      final isSelected =
                          controller.selectedVehicleType.value == type;

                      return _buildVehicleOption(
                        type: type,
                        name: name,
                        icon: icon,
                        pricePerKm: pricePerKm,
                        description: description,
                        isSelected: isSelected,
                        onTap: () => controller.selectVehicleType(type),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Price estimation
                Obx(
                  () => controller.estimatedPrice.value > 0
                      ? _buildPriceCard()
                      : const SizedBox(),
                ),

                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: controller.notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Catatan untuk driver (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActionButton(
                text: 'Pesan Sekarang',
                onPressed: controller.nextStage,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                text: 'Kembali',
                onPressed: controller.previousStage,
                isSecondary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stage 4: Finding Driver Stage (The Missing Part)
  Widget _buildFindingDriverStage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated searching icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Mencari driver terdekat...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tunggu sebentar, kami sedang mencarikan\ndriver terbaik untuk Anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          // Cancel button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildActionButton(
              text: 'Batalkan Pencarian',
              onPressed: controller.cancelSearch,
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildStageHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.previousStage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.textGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLocationItem(String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _selectLocation(location),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.history,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption({
    required String type,
    required String name,
    required IconData icon,
    required int pricePerKm,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${pricePerKm.toString()}/km',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimasi Perjalanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Obx(
                    () => Text(
                      '${controller.estimatedDistance.value.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Text(
                    'Jarak',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Obx(
                    () => Text(
                      '${controller.estimatedDuration.value} min',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Text(
                    'Waktu',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Obx(
                    () => Text(
                      'Rp ${controller.estimatedPrice.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    VoidCallback? onPressed,
    bool isEnabled = true,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? Colors.white
              : (isEnabled ? AppColors.primary : AppColors.textGrey),
          foregroundColor: isSecondary ? AppColors.primary : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary
                ? const BorderSide(color: AppColors.primary)
                : BorderSide.none,
          ),
          elevation: isSecondary ? 0 : 2,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Utility methods
  void _swapLocations() {
    final pickup = controller.pickupController.text;
    final destination = controller.destinationController.text;

    controller.pickupController.text = destination;
    controller.destinationController.text = pickup;
  }

  void _selectLocation(String location) {
    if (controller.pickupController.text.isEmpty) {
      controller.setPickupLocation(
        location,
        controller.pickupLatLng!,
      ); // Fixed to call setPickupLocation
    } else if (controller.destinationController.text.isEmpty) {
      controller.setDestinationLocation(
        location,
        controller.destLatLng!,
      ); // Fixed to call setDestinationLocation
    }
  }

  void _showLocationPicker(bool isPickup) {
    final TextEditingController searchController = TextEditingController();

    Get.bottomSheet(
      Container(
        // Sesuaikan tinggi agar keyboard tidak menutupi
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isPickup
                          ? 'Cari Lokasi Penjemputan'
                          : 'Cari Lokasi Tujuan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
            ),

            // --- KOLOM PENCARIAN BARU ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                autofocus: true, // Langsung fokus agar keyboard muncul
                decoration: InputDecoration(
                  hintText: "Ketik nama tempat (contoh: Unsoed)",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Panggil fungsi pencarian di controller saat tombol panah ditekan
                      controller.searchLocationFromText(
                        searchController.text,
                        isPickup,
                      );
                    },
                  ),
                ),
                onSubmitted: (value) {
                  // Panggil fungsi pencarian di controller saat tekan Enter/Search di keyboard
                  controller.searchLocationFromText(value, isPickup);
                },
              ),
            ),
            // -----------------------------

            // Loading Indicator saat mencari
            Obx(
              () => controller.isLoading.value
                  ? const LinearProgressIndicator(color: AppColors.primary)
                  : const SizedBox.shrink(),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Saran Cepat:",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  // Mock locations tetap ada sebagai opsi cepat
                  ...[
                    'Universitas Jenderal Soedirman',
                    'Terminal Purwokerto',
                    'Alun-alun Purwokerto',
                    'Stasiun Purwokerto',
                    'RITA SuperMall Purwokerto',
                  ].map((locationName) {
                    return ListTile(
                      leading: const Icon(
                        Icons.history,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(locationName),
                      onTap: () {
                        // Saat saran diklik, kita juga lakukan pencarian koordinat real-nya
                        controller.searchLocationFromText(
                          locationName,
                          isPickup,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
