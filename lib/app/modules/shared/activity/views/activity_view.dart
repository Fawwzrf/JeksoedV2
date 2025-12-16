// filepath: lib/app/modules/shared/activity/views/activity_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/activity_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/currency_formatter.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Riwayat Aktivitas',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _getTabController(context),
              indicatorColor: AppColors.primary,
              labelColor: AppColors.textBlack,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Selesai'),
                Tab(text: 'Dibatalkan'),
              ],
              onTap: controller.onTabSelected,
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              final state = controller.uiState.value;

              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (state.filteredRides.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.filteredRides.length,
                itemBuilder: (context, index) {
                  final historyItem = state.filteredRides[index];
                  return _buildHistoryCard(historyItem, state.isDriver);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  TabController _getTabController(BuildContext context) {
    return DefaultTabController.of(context);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Kamu belum punya riwayat perjalanan di kategori ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(RideHistoryDisplay historyItem, bool isDriverView) {
    final ride = historyItem.ride;
    final statusText = ride.status == "completed" ? "Selesai" : "Dibatalkan";
    final statusColor = ride.status == "completed"
        ? const Color(0xFF219800)
        : Colors.red;

    final formattedDate = ride.createdAt != null
        ? DateFormat('d MMMM yyyy', 'id_ID').format(ride.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => controller.navigateToDetail(ride.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Content row
                IntrinsicHeight(
                  child: Row(
                    children: [
                      // Route column
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRouteRow(
                              Icons.radio_button_checked,
                              AppColors.info,
                              ride.pickupAddress.isNotEmpty
                                  ? ride.pickupAddress
                                  : 'Lokasi Jemput',
                            ),
                            const SizedBox(height: 8),
                            _buildRouteRow(
                              Icons.location_on,
                              Colors.red,
                              ride.destinationAddress.isNotEmpty
                                  ? ride.destinationAddress
                                  : 'Lokasi Tujuan',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Vertical divider
                      Container(width: 1, color: Colors.grey.shade300),

                      const SizedBox(width: 16),

                      // Info column
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDriverView ? 'Penumpang' : 'Driver',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              historyItem.otherUserName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              formatCurrency(ride.fare ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Detail button
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Detail Pesanan >',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color iconColor, String location) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Wrapper widget with DefaultTabController
class ActivityViewWithTabs extends StatelessWidget {
  const ActivityViewWithTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: const ActivityView());
  }
}
