import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../shared/activity/controllers/activity_controller.dart';
import '../../../../../utils/app_colors.dart';

class DriverActivityView extends GetView<ActivityController> {
  const DriverActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller dipanggil/di-refresh saat halaman dibuka
    controller.fetchUserRoleAndHistory();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Aktivitas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Stats Header (Dihitung dari data controller)
          _buildStatsHeader(),

          // Filter Tabs
          _buildFilterTabs(),

          // Trip History List
          Expanded(
            child: Obx(() {
              final state = controller.uiState.value;

              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }

              if (state.filteredRides.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat aktivitas',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchUserRoleAndHistory(),
                color: AppColors.primaryGreen,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: state.filteredRides.length,
                  itemBuilder: (context, index) {
                    final historyItem = state.filteredRides[index];
                    return _buildTripCard(historyItem);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Obx(() {
      // Logika menghitung statistik HARI INI
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      final todayCompletedTrips = controller.uiState.value.rideHistoryItems
          .where((item) {
            final rideDate = item.ride.completedAt ?? item.ride.createdAt;
            if (rideDate == null) return false;

            final itemDateStr = DateFormat('yyyy-MM-dd').format(rideDate);
            return itemDateStr == todayStr && item.ride.status == 'completed';
          })
          .toList();

      final tripCount = todayCompletedTrips.length;

      // Hitung total pendapatan kotor hari ini
      final totalRevenue = todayCompletedTrips.fold<int>(0, (sum, item) {
        return sum + (item.ride.fare ?? 0);
      });

      // Simulasi Pendapatan Bersih (misal potongan aplikasi 10%)
      // Ubah logika ini sesuai kebutuhan bisnis Anda
      final netEarnings = (totalRevenue * 0.9).toInt();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Aktivitas Hari Ini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Trip',
                    value: '$tripCount',
                    subtitle: 'Selesai',
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pendapatan',
                    value: _formatCurrency(netEarnings),
                    subtitle: 'Bersih (Est)',
                    icon: Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(child: _buildTabButton('Semua', 0)),
            Expanded(child: _buildTabButton('Selesai', 1)),
            Expanded(child: _buildTabButton('Dibatalkan', 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = controller.uiState.value.selectedTab == index;
    return GestureDetector(
      onTap: () => controller.onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(RideHistoryDisplay historyItem) {
    final ride = historyItem.ride;
    final isCompleted = ride.status == 'completed';

    // Format Waktu
    final timeStr = ride.createdAt != null
        ? DateFormat('HH:mm').format(ride.createdAt!)
        : '-';

    // Format Jarak
    final distanceStr = '${(ride.distance ?? 0).toStringAsFixed(1)} km';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.navigateToDetail(ride.id),
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.primaryGreen.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCompleted ? 'SELESAI' : 'DIBATALKAN',
                            style: TextStyle(
                              color: isCompleted
                                  ? AppColors.primaryGreen
                                  : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatCurrency(ride.fare ?? 0),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Passenger Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      backgroundImage: historyItem.otherUserPhoto != null
                          ? NetworkImage(historyItem.otherUserPhoto!)
                          : null,
                      child: historyItem.otherUserPhoto == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryGreen,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        historyItem.otherUserName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      distanceStr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Route Info
                Column(
                  children: [
                    _buildRouteRow(
                      Icons.radio_button_checked,
                      AppColors.primaryGreen,
                      ride.pickupAddress ?? 'Lokasi Jemput',
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      height: 16,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _buildRouteRow(
                      Icons.location_on,
                      Colors.red,
                      ride.destinationAddress ?? 'Tujuan',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000) {
      double kAmount = amount / 1000;
      return 'Rp ${kAmount.toStringAsFixed(kAmount.truncateToDouble() == kAmount ? 0 : 1)}K';
    }
    return 'Rp $amount';
  }
}
