// filepath: lib/app/modules/shared/activity_detail/views/activity_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../controllers/activity_detail_controller.dart';
import '../../../../../utils/app_colors.dart';

class ActivityDetailView extends GetView<ActivityDetailController> {
  const ActivityDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final state = controller.uiState.value;

        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.rideRequest == null) {
          return const Center(child: Text('Gagal memuat detail perjalanan.'));
        }

        return ActivityDetailContent(
          state: state,
          onChatClick: controller.onChatClick,
        );
      }),
    );
  }
}

class ActivityDetailContent extends StatefulWidget {
  final ActivityDetailUiState state;
  final VoidCallback onChatClick;

  const ActivityDetailContent({
    super.key,
    required this.state,
    required this.onChatClick,
  });

  @override
  State<ActivityDetailContent> createState() => _ActivityDetailContentState();
}

class _ActivityDetailContentState extends State<ActivityDetailContent> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Map Section
          SizedBox(
            height: 200,
            child: widget.state.polylinePoints.isNotEmpty
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.state.polylinePoints.first,
                      zoom: 13,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      _fitPolylineInView();
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: widget.state.polylinePoints,
                        color: AppColors.primary,
                        width: 4,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('pickup'),
                        position: widget.state.polylinePoints.first,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                      ),
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: widget.state.polylinePoints.last,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text(
                        'Peta tidak tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ),

          // Detail Sheet
          _DetailSheet(state: widget.state, onChatClick: widget.onChatClick),
        ],
      ),
    );
  }

  void _fitPolylineInView() {
    if (_mapController == null || widget.state.polylinePoints.isEmpty) return;
    final bounds = _boundsFromLatLngList(widget.state.polylinePoints);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;

    for (LatLng latLng in list) {
      minLat = minLat < latLng.latitude ? minLat : latLng.latitude;
      maxLat = maxLat > latLng.latitude ? maxLat : latLng.latitude;
      minLng = minLng < latLng.longitude ? minLng : latLng.longitude;
      maxLng = maxLng > latLng.longitude ? maxLng : latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final ActivityDetailUiState state;
  final VoidCallback onChatClick;

  const _DetailSheet({required this.state, required this.onChatClick});

  @override
  Widget build(BuildContext context) {
    final ride = state.rideRequest!;
    final formattedDate = ride.createdAt != null
        ? DateFormat('d MMMM yyyy', 'id_ID').format(ride.createdAt!)
        : '-';
    final formattedStartTime = ride.createdAt != null
        ? DateFormat('HH:mm', 'id_ID').format(ride.createdAt!)
        : '-';
    final formattedEndTime = ride.completedAt != null
        ? DateFormat('HH:mm', 'id_ID').format(ride.completedAt!)
        : formattedStartTime;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          if (state.isDriver)
            _UserInfoRow(
              user: state.otherUser,
              isChatEnabled: state.isChatEnabled,
              onChatClick: onChatClick,
            )
          else
            _DriverInfoRow(
              driver: state.otherUser,
              isChatEnabled: state.isChatEnabled,
              onChatClick: onChatClick,
            ),

          const Divider(height: 24),

          // Route Section
          _RouteRow(
            icon: Icons.radio_button_checked,
            iconColor: AppColors.info,
            location: ride.pickupAddress.isNotEmpty
                ? ride.pickupAddress
                : 'Lokasi Jemput',
          ),
          const SizedBox(height: 8),
          _RouteRow(
            icon: Icons.location_on,
            iconColor: Colors.red,
            location: ride.destinationAddress.isNotEmpty
                ? ride.destinationAddress
                : 'Lokasi Tujuan',
          ),

          const Divider(height: 24),

          // Time Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TimeColumn('Waktu Berangkat', formattedStartTime),
              _TimeColumn('Waktu Tiba', formattedEndTime),
            ],
          ),

          const Divider(height: 24),

          // Date & Payment Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tanggal', style: TextStyle(color: Colors.grey)),
              Text(
                formattedDate,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'Rp ${ride.fare}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            '* Fitur chat hanya tersedia hingga 30 menit setelah perjalanan selesai.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const Divider(height: 32),

          // Rating Section
          _RatingSection(ride: ride),
        ],
      ),
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  final dynamic user;
  final bool isChatEnabled;
  final VoidCallback onChatClick;

  const _UserInfoRow({
    required this.user,
    required this.isChatEnabled,
    required this.onChatClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: user?.photoUrl != null
              ? NetworkImage(user!.photoUrl!)
              : null,
          child: user?.photoUrl == null
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            user?.name ?? 'Pengguna',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: isChatEnabled ? onChatClick : null,
          icon: Icon(
            Icons.chat,
            color: isChatEnabled ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _DriverInfoRow extends StatelessWidget {
  final dynamic driver;
  final bool isChatEnabled;
  final VoidCallback onChatClick;

  const _DriverInfoRow({
    required this.driver,
    required this.isChatEnabled,
    required this.onChatClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: driver?.photoUrl != null
              ? NetworkImage(driver!.photoUrl!)
              : null,
          child: driver?.photoUrl == null
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver?.name ?? 'Driver',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                driver?.licensePlate ?? '...',
                style: const TextStyle(color: Colors.grey),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _getFormattedRating(driver),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: isChatEnabled ? onChatClick : null,
          icon: Icon(
            Icons.chat,
            color: isChatEnabled ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getFormattedRating(dynamic user) {
    if (user == null || user.ratingCount == 0) return '0.0';
    final avg = user.totalRating / user.ratingCount;
    return avg.toStringAsFixed(1);
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String location;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(location, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String time;

  const _TimeColumn(this.label, this.time);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

class _RatingSection extends StatelessWidget {
  final dynamic ride;

  const _RatingSection({required this.ride});

  @override
  Widget build(BuildContext context) {
    final rating = ride.rating ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Rating Perjalanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (rating > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              );
            }),
          ),
        ] else ...[
          const Text(
            'Belum ada rating untuk perjalanan ini',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
