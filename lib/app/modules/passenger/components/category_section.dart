import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class Category {
  final String name;
  final String iconPath;
  final String? tag;

  Category({required this.name, required this.iconPath, this.tag});
}

class CategoryGrid extends StatelessWidget {
  final Function(String) onCategoryClick;

  const CategoryGrid({super.key, required this.onCategoryClick});

  @override
  Widget build(BuildContext context) {
    final categories = [
      Category(
        name: "JekMotor",
        iconPath: "assets/images/motor_icon.xml",
        tag: "START7K",
      ),
      Category(
        name: "JekMobil",
        iconPath: "assets/images/car_icon.xml",
        tag: "START13K",
      ),
      Category(
        name: "JekClean",
        iconPath: "assets/images/cleaning_icon.xml",
        tag: "-10%",
      ),
      Category(name: "Lainnya", iconPath: "assets/images/more_icon.xml"),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        return CategoryItem(
          category: category,
          onClick: () => onCategoryClick(category.name),
        );
      }).toList(),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback onClick;

  const CategoryItem({super.key, required this.category, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(category.name),
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              if (category.tag != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.tag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String categoryName) {
    switch (categoryName) {
      case "JekMotor":
        return Icons.motorcycle;
      case "JekMobil":
        return Icons.directions_car;
      case "JekClean":
        return Icons.cleaning_services;
      case "Lainnya":
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }
}
