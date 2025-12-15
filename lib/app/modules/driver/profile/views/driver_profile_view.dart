import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/profile/controllers/profile_controller.dart'; // Import Shared Controller
import '../../../../../utils/app_colors.dart';

// Ubah menjadi GetView<ProfileController>
class DriverProfileView extends GetView<ProfileController> {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh data saat halaman dibuka
    controller.fetchUserData();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Obx(() {
        final state = controller.uiState.value;

        return CustomScrollView(
          slivers: [
            // App Bar with Profile Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Profile Picture
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: state.photoUrl.isNotEmpty
                                ? Image.network(
                                    state.photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildDefaultAvatar(),
                                  )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name (Real Data)
                        Text(
                          state.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email (Real Data)
                        Text(
                          state.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats Cards (Real Data)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Rating',
                            value: state.rating, // Data Asli
                            icon: Icons.star,
                            iconColor: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Trip Selesai',
                            value: state.totalTrips, // Data Asli
                            icon: Icons.check_circle,
                            iconColor: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Bergabung',
                            value: state.joinDate, // Data Asli
                            icon: Icons.calendar_today,
                            iconColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Menu Items
                    _buildMenuSection(),

                    const SizedBox(height: 20),

                    // Logout Button (Using Controller logic)
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 40),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person,
            title: 'Edit Profil',
            subtitle: 'Ubah informasi profil Anda',
            onTap: controller.navigateToEditProfile,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Bantuan',
            subtitle: 'FAQ dan dukungan pelanggan',
            onTap: controller.navigateToAbout,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.description,
            title: 'Syarat & Ketentuan',
            subtitle: 'Baca syarat dan ketentuan',
            onTap: controller.navigateToTnc,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey.shade400,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 24),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        subtitle: const Text(
          'Keluar dari akun driver',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
        onTap: controller.onLogoutClick, // Gunakan method controller yang ada
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
