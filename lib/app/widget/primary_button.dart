import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color containerColor;
  final Color contentColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    Color? containerColor,
    Color? contentColor,
  })  : containerColor = containerColor ?? AppColors.primary,
        contentColor = contentColor ?? AppColors.textWhite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor,
          foregroundColor: contentColor,
          disabledBackgroundColor: AppColors.textGrey,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
