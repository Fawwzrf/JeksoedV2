import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../utils/app_colors.dart';
import 'package:jeksoedv2/data/models/place_models.dart';

class SearchStage extends StatelessWidget {
  final String pickupQuery;
  final String destinationQuery;
  final List<PlacePrediction> predictions;
  final List<SavedPlace> savedPlaces;
  final Function(String) onPickupQueryChanged;
  final Function(String) onDestinationQueryChanged;
  final Function(PlacePrediction) onPredictionSelected;
  final Function(SavedPlace) onSavedPlaceSelected;
  final VoidCallback onTextFieldFocus;
  final VoidCallback onLocationClick;
  final Function({required bool isPickup}) clearQuery;

  const SearchStage({
    super.key,
    required this.pickupQuery,
    required this.destinationQuery,
    required this.predictions,
    required this.savedPlaces,
    required this.onPickupQueryChanged,
    required this.onDestinationQueryChanged,
    required this.onPredictionSelected,
    required this.onSavedPlaceSelected,
    required this.onTextFieldFocus,
    required this.onLocationClick,
    required this.clearQuery,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Card
          Card(
            elevation: 0,
            
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  // Pickup TextField
                  _buildLocationTextField(
                    query: pickupQuery,
                    hint: 'Lokasi Jemput',
                    isPickup: true,
                    icon: Icons.circle,
                    iconColor: AppColors.info,
                    onChanged: onPickupQueryChanged,
                    onTap: onTextFieldFocus,
                    onLocationClick: onLocationClick,
                    onClear: () => clearQuery(isPickup: true),
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 1),
                  const SizedBox(height: 4),
                  // Destination TextField
                  _buildLocationTextField(
                    query: destinationQuery,
                    hint: 'Mau ke mana, nih?',
                    isPickup: false,
                    image: 'assets/images/point_icon.svg',
                    onChanged: onDestinationQueryChanged,
                    onTap: onTextFieldFocus,
                    onClear: () => clearQuery(isPickup: false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Predictions List
          if (predictions.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hasil Pencarian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...predictions.map((prediction) {
              return _PredictionItem(
                prediction: prediction,
                onTap: () => onPredictionSelected(prediction),
              );
            }),
          ]
          // Saved Places Section
          else if (savedPlaces.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.favorite, color: Colors.red, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Tersimpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            ...savedPlaces.map((place) {
              return _SavedPlaceItem(
                place: place,
                onTap: () => onSavedPlaceSelected(place),
              );
            }),
          ],

          const SizedBox(height: 100), // Extra space for keyboard
        ],
      ),
    );
  }

  Widget _buildLocationTextField({
    required String query,
    required String hint,
    required bool isPickup,
    IconData? icon,
    Color? iconColor,
    String? image,
    required Function(String) onChanged,
    required VoidCallback onTap,
    VoidCallback? onLocationClick,
    VoidCallback? onClear,
  }) {
    return TextField(
      controller: TextEditingController(text: query)
        ..selection = TextSelection.collapsed(offset: query.length),
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: image != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: image.endsWith('.svg')
                    ? SvgPicture.asset(
                        image,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        image,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
              )
            : Icon(icon, color: iconColor, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onClear,
              )
            : (isPickup && query.isEmpty
                ? IconButton(
                    icon: const Icon(Icons.my_location, size: 20),
                    onPressed: onLocationClick,
                  )
                : null),
      ),
    );
  }
}

class _PredictionItem extends StatelessWidget {
  final PlacePrediction prediction;
  final VoidCallback onTap;

  const _PredictionItem({
    required this.prediction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.location_on, color: Colors.grey),
      title: Text(
        prediction.mainText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        prediction.secondaryText,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}

class _SavedPlaceItem extends StatelessWidget {
  final SavedPlace place;
  final VoidCallback onTap;

  const _SavedPlaceItem({
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const Icon(Icons.location_on, color: Colors.grey, size: 24),
      title: Row(
        children: [
          Expanded(
            child: Text(
              place.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            place.distance,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text(
        place.address,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.favorite, color: Colors.red, size: 20),
    );
  }
}
