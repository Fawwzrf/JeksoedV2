import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Wajib import ini
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
              return _buildPickupConfirmStage(); // Map ada di sini
            case OrderStage.routeConfirm:
              return _buildRouteConfirmStage();
            case OrderStage.findingDriver:
              return _buildFindingDriverStage();
          }
        }),
      ),
    );
  }

  // =========================================================
  // STAGE 1: SEARCH
  // =========================================================
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
                      _buildLocationInput(
                        icon: Icons.radio_button_checked,
                        iconColor: AppColors.success,
                        label: 'Dari',
                        hint: 'Lokasi penjemputan',
                        controller: controller.pickupController,
                        onTap: () => _showLocationPicker(true),
                      ),
                      const SizedBox(height: 16),
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
                              onTap: _swapLocations,
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
                      _buildLocationInput(
                        icon: Icons.location_on,
                        iconColor: AppColors.error,
                        label: 'Ke',
                        hint: 'Lokasi tujuan',
                        controller: controller.destinationController,
                        onTap: () => _showLocationPicker(false),
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
                ...[
                  'Universitas Jenderal Soedirman',
                  'Terminal Purwokerto',
                  'Plaza Asia',
                ].map((location) => _buildRecentLocationItem(location)),
              ],
            ),
          ),
        ),

        // Continue Button
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

  // =========================================================
  // STAGE 2: PICKUP CONFIRM (MAPS)
  // =========================================================
  Widget _buildPickupConfirmStage() {
    return Column(
      children: [
        _buildStageHeader('Konfirmasi Penjemputan'),
        Expanded(
          child: Stack(
            children: [
              // 1. GOOGLE MAPS (Fixed: Bukan Icon lagi)
              Obx(
                () => GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target:
                        controller.pickupLatLng ??
                        const LatLng(-7.4242, 109.2303),
                    zoom: 15,
                  ),
                  onMapCreated: controller.onMapCreated,
                  markers: controller.markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),

              // 2. Pickup Detail Card
              Positioned(
                bottom: 20,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STAGE 3: ROUTE CONFIRM
  // =========================================================
  Widget _buildRouteConfirmStage() {
    return Column(
      children: [
        _buildStageHeader('Pilih Kendaraan'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Route
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Vehicle Options
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
                      return _buildVehicleOption(
                        type: type,
                        name: vehicle['name'] as String,
                        icon: vehicle['icon'] as IconData,
                        pricePerKm: (vehicle['pricePerKm'] ?? 0) as int,
                        description: vehicle['description'] as String,
                        isSelected:
                            controller.selectedVehicleType.value == type,
                        onTap: () => controller.selectVehicleType(type),
                      );
                    }).toList(),
                  ),
                ),

                // Price
                const SizedBox(height: 24),
                Obx(
                  () => controller.estimatedPrice.value > 0
                      ? _buildPriceCard()
                      : const SizedBox(),
                ),

                // Notes
                const SizedBox(height: 16),
                TextField(
                  controller: controller.notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Catatan untuk driver (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Button
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

  // =========================================================
  // STAGE 4: FINDING DRIVER
  // =========================================================
  Widget _buildFindingDriverStage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

  // =========================================================
  // HELPER WIDGETS & METHODS
  // =========================================================

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      return Text(
                        value.text.isEmpty ? hint : value.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: value.text.isEmpty
                              ? Colors.grey
                              : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLocationItem(String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _selectLocation(location), // Fix logic here
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        tileColor: Colors.white,
        leading: const Icon(Icons.history, color: AppColors.textSecondary),
        title: Text(
          location,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 28,
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
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Rp $pricePerKm/km',
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
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Obx(
                () => Text(
                  '${controller.estimatedDistance.value.toStringAsFixed(1)} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Text('Jarak', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              Obx(
                () => Text(
                  '${controller.estimatedDuration.value} min',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Text('Waktu', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              Obx(
                () => Text(
                  'Rp ${controller.estimatedPrice.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Text('Total', style: TextStyle(fontSize: 12)),
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

  // =========================================================
  // LOGIC & SHEET
  // =========================================================

  void _swapLocations() {
    final pickup = controller.pickupController.text;
    final destination = controller.destinationController.text;
    controller.pickupController.text = destination;
    controller.destinationController.text = pickup;
  }

  void _selectLocation(String locationName) {
    // FIX: Gunakan selectLocation dengan membuat PlaceResult baru
    // Kita asumsikan ini lokasi cepat (koordinat null dulu, biar controller cari)
    bool isPickup = controller.pickupController.text.isEmpty;

    // Logic: Jika pickup kosong -> isi pickup. Jika tidak -> isi destination.
    controller.selectLocation(
      PlaceResult(title: locationName, subtitle: '', latLng: null),
      isPickup,
    );
  }

  void _showLocationPicker(bool isPickup) {
    final TextEditingController searchController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    controller.searchResults.clear();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
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
                      isPickup ? 'Cari Lokasi Jemput' : 'Cari Lokasi Tujuan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                focusNode: focusNode,
                autofocus: true,
                onChanged: (val) => controller.onSearchTextChanged(val),
                decoration: InputDecoration(
                  hintText: "Cari nama tempat, jalan...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isSearchingLocation.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (controller.searchResults.isNotEmpty) {
                  return ListView.separated(
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final place = controller.searchResults[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(
                          place.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          place.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => controller.selectLocation(
                          place,
                          isPickup,
                        ), // FIX: variable 'place' is correct here
                      );
                    },
                  );
                }
                return ListView(
                  children: [
                    if (searchController.text.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Saran Cepat",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildQuickSuggestion(
                        "Universitas Jenderal Soedirman",
                        isPickup,
                      ),
                      _buildQuickSuggestion(
                        "Terminal Bulupitu Purwokerto",
                        isPickup,
                      ),
                      _buildQuickSuggestion("Stasiun Purwokerto", isPickup),
                      _buildQuickSuggestion("RITA SuperMall", isPickup),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    ).then((_) => focusNode.dispose());

    // Auto focus delay hack for bottom sheet
    Future.delayed(const Duration(milliseconds: 500), () {
      if (focusNode.canRequestFocus) focusNode.requestFocus();
    });
  }

  Widget _buildQuickSuggestion(String name, bool isPickup) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(name),
      onTap: () {
        // FIX: Panggil selectLocation via PlaceResult
        controller.selectLocation(
          PlaceResult(title: name, subtitle: '', latLng: null),
          isPickup,
        );
      },
    );
  }
}
