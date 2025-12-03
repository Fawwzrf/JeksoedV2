// filepath: lib/app/modules/driver/home/components/driver_info_card.dart

import 'package:flutter/material.dart';
import '../../../../../data/models/driver_profile.dart';
import '../../../../../utils/app_colors.dart';

class DriverInfoCard extends StatelessWidget {
  final DriverProfile? profile;
  final bool isOnline;
  final bool isLoadingProfile;
  final VoidCallback onToggleStatus;

  const DriverInfoCard({
    super.key,
    required this.profile,
    required this.isOnline,
    required this.isLoadingProfile,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Section
              _buildProfileSection(),

              const SizedBox(height: 16),

              // Stats Section
              _buildStatsSection(),

              const SizedBox(height: 20),

              // Toggle Button
              _buildToggleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        // Profile Picture
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 3),
          ),
          child: ClipOval(
            child: isLoadingProfile
                ? const CircularProgressIndicator()
                : profile?.photoUrl != null
                ? Image.network(
                    profile!.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),

        const SizedBox(width: 16),

        // Profile Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoadingProfile ? 'Loading...' : (profile?.name ?? 'Driver'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLoadingProfile
                    ? ''
                    : (profile?.licensePlate ?? 'No license plate'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 30),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.account_balance_wallet,
              label: 'Saldo',
              value: isLoadingProfile ? 'Rp 0' : (profile?.balance ?? 'Rp 0'),
              color: AppColors.primaryGreen,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              icon: Icons.star,
              label: 'Rating',
              value: isLoadingProfile ? '0.0' : (profile?.rating ?? '0.0'),
              color: Colors.amber,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_taxi,
              label: 'Order',
              value: isLoadingProfile ? '0' : (profile?.orderCount ?? '0'),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onToggleStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOnline
              ? Colors.red.shade500
              : AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOnline ? Icons.power_settings_new : Icons.play_arrow,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'GO OFFLINE' : 'GO ONLINE',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
