import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class SavedPlace {
  final String title;
  final String address;
  final String distance;

  SavedPlace({
    required this.title,
    required this.address,
    required this.distance,
  });
}

class SearchStage extends StatefulWidget {
  final String pickupQuery;
  final String destinationQuery;
  final List<dynamic> predictions;
  final List<SavedPlace> savedPlaces;
  final Function(String) onDestinationQueryChanged;
  final Function(dynamic) onPredictionSelected;
  final Function(SavedPlace) onSavedPlaceSelected;
  final VoidCallback onTextFieldFocus;
  final VoidCallback onLocationClick;

  const SearchStage({
    super.key,
    required this.pickupQuery,
    required this.destinationQuery,
    required this.predictions,
    required this.savedPlaces,
    required this.onDestinationQueryChanged,
    required this.onPredictionSelected,
    required this.onSavedPlaceSelected,
    required this.onTextFieldFocus,
    required this.onLocationClick,
  });

  @override
  State<SearchStage> createState() => _SearchStageState();
}

class _SearchStageState extends State<SearchStage> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _destinationController.text = widget.destinationQuery;
    _destinationController.addListener(() {
      widget.onDestinationQueryChanged(_destinationController.text);
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search TextField
        SearchTextField(
          pickupQuery: widget.pickupQuery,
          destinationController: _destinationController,
          focusNode: _focusNode,
          onTextFieldFocus: widget.onTextFieldFocus,
          onLocationClick: widget.onLocationClick,
        ),

        const SizedBox(height: 16),

        // Predictions List
        if (widget.predictions.isNotEmpty) ...[
          const Text(
            "Hasil Pencarian",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.predictions.map((prediction) {
            return PredictionItem(
              prediction: prediction,
              onClick: () => widget.onPredictionSelected(prediction),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Saved Places Section
        if (widget.savedPlaces.isNotEmpty)
          TersimpanSection(
            savedPlaces: widget.savedPlaces,
            onSavedPlaceSelected: widget.onSavedPlaceSelected,
          ),
      ],
    );
  }
}

class SearchTextField extends StatelessWidget {
  final String pickupQuery;
  final TextEditingController destinationController;
  final FocusNode focusNode;
  final VoidCallback onTextFieldFocus;
  final VoidCallback onLocationClick;

  const SearchTextField({
    super.key,
    required this.pickupQuery,
    required this.destinationController,
    required this.focusNode,
    required this.onTextFieldFocus,
    required this.onLocationClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Pickup Location Row
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onLocationClick,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      pickupQuery,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Divider(),

          // Destination TextField Row
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: destinationController,
                  focusNode: focusNode,
                  onTap: onTextFieldFocus,
                  decoration: const InputDecoration(
                    hintText: "Mau kemana?",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PredictionItem extends StatelessWidget {
  final dynamic prediction;
  final VoidCallback onClick;

  const PredictionItem({
    super.key,
    required this.prediction,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClick,
      leading: Icon(Icons.location_on, color: AppColors.primary),
      title: Text(
        prediction.toString(), // Sesuaikan dengan struktur data prediction
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        "Hasil pencarian",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class TersimpanSection extends StatelessWidget {
  final List<SavedPlace> savedPlaces;
  final Function(SavedPlace) onSavedPlaceSelected;

  const TersimpanSection({
    super.key,
    required this.savedPlaces,
    required this.onSavedPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tersimpan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...savedPlaces.map((place) {
          return SavedPlaceItem(
            place: place,
            onClick: () => onSavedPlaceSelected(place),
          );
        }),
      ],
    );
  }
}

class SavedPlaceItem extends StatelessWidget {
  final SavedPlace place;
  final VoidCallback onClick;

  const SavedPlaceItem({super.key, required this.place, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClick,
      leading: Icon(Icons.bookmark, color: AppColors.primary),
      title: Text(
        place.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        "${place.address} • ${place.distance}",
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
