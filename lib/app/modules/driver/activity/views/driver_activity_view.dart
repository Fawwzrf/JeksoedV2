// filepath: lib/app/modules/driver/activity/views/driver_activity_view.dart

import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class DriverActivityView extends StatelessWidget {
  const DriverActivityView({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Stats Header
          Container(
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
                        value: '12',
                        subtitle: 'Selesai',
                        icon: Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pendapatan',
                        value: 'Rp 245K',
                        subtitle: 'Hari ini',
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
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
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    title: 'Semua',
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    title: 'Selesai',
                    isSelected: false,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    title: 'Dibatalkan',
                    isSelected: false,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),

          // Trip History List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5, // Demo data
              itemBuilder: (context, index) {
                return _buildTripCard(index);
              },
            ),
          ),
        ],
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

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildTripCard(int index) {
    final List<Map<String, dynamic>> demoTrips = [
      {
        'passenger': 'Ahmad Fauzi',
        'from': 'Stasiun Purwokerto',
        'to': 'Universitas Jenderal Soedirman',
        'fare': 15000,
        'distance': '3.2 km',
        'time': '10:30',
        'status': 'completed',
      },
      {
        'passenger': 'Sari Wulandari',
        'from': 'Mall Rita Supermall',
        'to': 'Jl. Gatot Subroto 15',
        'fare': 12000,
        'distance': '2.8 km',
        'time': '11:15',
        'status': 'completed',
      },
      {
        'passenger': 'Budi Santoso',
        'from': 'Terminal Purwokerto',
        'to': 'Jl. Ahmad Yani 25',
        'fare': 18000,
        'distance': '4.1 km',
        'time': '12:45',
        'status': 'cancelled',
      },
      {
        'passenger': 'Rina Susanti',
        'from': 'Kampus UNSOED',
        'to': 'Jl. Sudirman 8',
        'fare': 14000,
        'distance': '3.5 km',
        'time': '14:20',
        'status': 'completed',
      },
      {
        'passenger': 'Andi Prakoso',
        'from': 'Pasar Wage',
        'to': 'Perumahan Griya Satria',
        'fare': 22000,
        'distance': '5.2 km',
        'time': '15:30',
        'status': 'completed',
      },
    ];

    if (index >= demoTrips.length) return const SizedBox.shrink();

    final trip = demoTrips[index];
    final isCompleted = trip['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                        trip['time'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${trip['fare']}',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Passenger info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    trip['passenger'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    trip['distance'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Route
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.radio_button_checked,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip['from'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    height: 16,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip['to'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
