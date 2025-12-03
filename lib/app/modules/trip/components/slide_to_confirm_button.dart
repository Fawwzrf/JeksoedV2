// filepath: lib/app/modules/trip/components/slide_to_confirm_button.dart

import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

class SlideToConfirmButton extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;

  const SlideToConfirmButton({
    super.key,
    required this.text,
    required this.onConfirmed,
  });

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragPosition = 0.0;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, _getMaxDragDistance());
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final threshold = _getMaxDragDistance() * 0.8;

    if (_dragPosition >= threshold && !_isConfirmed) {
      _isConfirmed = true;
      widget.onConfirmed();
      _resetButton();
    } else {
      _resetButton();
    }
  }

  void _resetButton() {
    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _dragPosition = 0.0;
        _isConfirmed = false;
      });
    });
  }

  double _getMaxDragDistance() {
    return MediaQuery.of(context).size.width - 32 - 56; // margin + thumb size
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [
          // Background text
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final progress = _dragPosition / _getMaxDragDistance();
                return Opacity(
                  opacity: 1.0 - progress,
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),

          // Draggable thumb
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final animatedPosition = _animation.isAnimating
                  ? _dragPosition * (1.0 - _animation.value)
                  : _dragPosition;

              return Positioned(
                left: animatedPosition,
                top: 4,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
