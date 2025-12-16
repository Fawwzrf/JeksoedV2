import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../utils/app_colors.dart';

class FindingDriverStage extends StatefulWidget {
  final VoidCallback onCancelClick;

  const FindingDriverStage({super.key, required this.onCancelClick});

  @override
  State<FindingDriverStage> createState() => _FindingDriverStageState();
}

class _FindingDriverStageState extends State<FindingDriverStage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Start the animation and repeat
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = 32.0;
    final padding = 32.0; // 16 * 2 for left and right padding
    final travelDistance = screenWidth - iconSize - padding;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Sedang mencari driver",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tunggu dulu, yaa",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Motor Animation with Progress Bar
          SizedBox(
            width: double.infinity,
            height: 60,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Column(
                  children: [
                    // Motor Icon
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: travelDistance * _animation.value),
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/images/motor_icon.svg',
                              width: 32,
                              height: 32,
                              
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: Colors.grey.shade300,
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onCancelClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFBEB), // Light yellow
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.close, size: 20, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Batalkan Pesanan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
