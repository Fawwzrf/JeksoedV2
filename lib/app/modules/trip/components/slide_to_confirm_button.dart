// filepath: lib/app/modules/trip/components/slide_to_confirm_button.dart

import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

class SlideToConfirmButton extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;
  final bool isLoading;

  const SlideToConfirmButton({
    super.key,
    required this.text,
    required this.onConfirmed,
    this.isLoading = false,
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
  double _maxWidth = 0.0;

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

  double _getMaxDragDistance() => _maxWidth - 56;

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isConfirmed || widget.isLoading) return;

    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, _getMaxDragDistance());
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isConfirmed || widget.isLoading) return;

    final threshold = _getMaxDragDistance() * 0.75;

    if (_dragPosition >= threshold) {
      setState(() {
        _dragPosition = _getMaxDragDistance();
        _isConfirmed = true;
      });
      widget.onConfirmed();
    } else {
      _resetButton();
    }
  }

  void _resetButton() {
    // Animasi balik ke kiri
    final start = _dragPosition;
    _controller.reset();

    Animation<double> animation = Tween<double>(
      begin: start,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() {
        _dragPosition = animation.value;
      });
    });

    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isConfirmed = false;
          _dragPosition = 0.0;
        });
      }
    });
  }

  @override
  void didUpdateWidget(SlideToConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika loading selesai dan status reset, kembalikan tombol
    if (!widget.isLoading && _isConfirmed) {
      _resetButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ambil lebar asli dari parent widget
        _maxWidth = constraints.maxWidth;

        return Container(
          height: 56,
          width: _maxWidth,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Stack(
            children: [
              // 1. Teks Latar Belakang
              Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Opacity(
                        opacity:
                            1.0 -
                            (_dragPosition /
                                (_getMaxDragDistance() == 0
                                    ? 1
                                    : _getMaxDragDistance())),
                        child: Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),

              // 2. Tombol Geser (Thumb)
              Positioned(
                left: widget.isLoading ? _getMaxDragDistance() : _dragPosition,
                top: 4,
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryGreen,
                            size: 24,
                          )
                        : const Icon(
                            Icons.keyboard_arrow_right,
                            color: AppColors.primary,
                            size: 32,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
