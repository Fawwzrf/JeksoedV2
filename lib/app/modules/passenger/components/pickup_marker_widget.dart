import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PickupMarkerWidget extends StatelessWidget {
  final String? photoUrl;

  const PickupMarkerWidget({super.key, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User photo with blue background
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF3386FF),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: photoUrl != null && photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : Container(
                        color: const Color(0xFF3386FF),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
              ),
            ),
          ),
          // Triangle pointer
          CustomPaint(
            size: const Size(20, 12),
            painter: _TrianglePainter(),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // Bottom center
      ..lineTo(0, 0) // Top left
      ..lineTo(size.width, 0) // Top right
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
