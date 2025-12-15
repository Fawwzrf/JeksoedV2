import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_passenger_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../passenger/components/components.dart';

class HomePassengerView extends GetView<HomePassengerController> {
  const HomePassengerView({super.key});  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Header dengan gambar
              SliverToBoxAdapter(
                child: _buildTopHeader(),
              ),
              
              // Main Content dalam Card putih
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSearchBar(),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Category Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CategoryGrid(onCategoryClick: controller.onCategoryClick),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Recent History Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildRecentHistoryWithComponent(),
                        ),
                        
                        
                        const SizedBox(height: 32),
                        
                        // Recommendation Section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              RecommendationSection(),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 16,
                top: 32,
                bottom: 16,
              ),
              child: Obx(
                () => Text(
                  "Halo, ${controller.userName.value}!",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),            ),
            
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Image.asset(
                'assets/images/home_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }Widget _buildSearchBar() {
    return GestureDetector(
      onTap: controller.onSearchClick,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Mau ke mana hari ini?",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.search,
              color: Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistoryWithComponent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Baru - baru ini..",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Lihat semua",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => RecentHistoryList(
              history: controller.recentTrips
                  .map(
                    (trip) => RideHistoryItem(
                      destinationName: trip['destination'],
                      destinationAddress: trip['address'],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
