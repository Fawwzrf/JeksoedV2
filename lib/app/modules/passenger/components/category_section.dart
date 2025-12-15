import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        iconPath: "assets/images/motor_icon.svg",
        tag: "START7K",
      ),
      Category(
        name: "JekMobil",
        iconPath: "assets/images/car_icon.svg",
        tag: "START13K",
      ),
      Category(
        name: "JekClean",
        iconPath: "assets/images/cleaning_icon.svg",
        tag: "-10%",
      ),
      Category(name: "Lainnya", iconPath: "assets/images/more_icon.svg"),
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
        mainAxisSize: MainAxisSize.min,
        children: [          Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon Container
              SvgPicture.asset(
                _getIconPath(category.name),
                width: 48,
                height: 48,
              ),
              // Tag (jika ada)
              if (category.tag != null)
                Positioned(
                  top: -10,
                  left: -10,
                  child: CustomPaint(
                    painter: TagPainter(),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Text(
                        category.tag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getIconPath(String categoryName) {
    switch (categoryName) {
      case "JekMotor":
        return "assets/images/motor_icon.svg";
      case "JekMobil":
        return "assets/images/car_icon.svg";
      case "JekClean":
        return "assets/images/cleaning_icon.svg";
      case "Lainnya":
        return "assets/images/more_icon.svg";
      default:
        return "assets/images/more_icon.svg";
    }
  }
}

// Custom Painter untuk membuat tag dengan pointer
class TagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF272343)
      ..style = PaintingStyle.fill;

    final path = Path();
    const cornerRadius = 8.0;
    const pointerWidth = 10.0;
    const pointerHeight = 8.0;

    // Start from top-left
    path.moveTo(0, 0);
    
    // Top-right with rounded corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(
      size.width, 0,
      size.width, cornerRadius,
    );
    
    // Right side
    path.lineTo(size.width, size.height - cornerRadius);
    
    // Bottom-right with rounded corner
    path.quadraticBezierTo(
      size.width, size.height,
      size.width - cornerRadius, size.height,
    );
    
    // Bottom side with pointer
    path.lineTo(pointerWidth, size.height);
    path.lineTo(pointerWidth, size.height + pointerHeight);
    path.lineTo(0, size.height);
    
    // Close path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
