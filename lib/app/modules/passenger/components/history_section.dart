import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

// Model untuk data RideRequest (sesuai dengan yang ada di Android)
class RideHistoryItem {
  final String? destinationName;
  final String? destinationAddress;

  RideHistoryItem({this.destinationName, this.destinationAddress});
}

class RecentHistoryList extends StatelessWidget {
  final List<RideHistoryItem> history;

  const RecentHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text(
        "Belum ada riwayat perjalanan.",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      );
    }

    return Column(
      children: history.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HistoryRowItem(item: item),
        );
      }).toList(),
    );
  }
}

class HistoryRowItem extends StatelessWidget {
  final RideHistoryItem item;

  const HistoryRowItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.destinationName ?? "Tujuan",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            item.destinationAddress ?? "Alamat tidak tersedia",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
