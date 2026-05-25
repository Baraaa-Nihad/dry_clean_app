// lib/components/Notification/QuantityIcon.dart

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

enum IconSize {
  extraSmall, // New smaller size: 18x18
  small, // Existing small size
  normal, // Existing normal size
}

class QuantityIcon extends StatelessWidget {
  final IconSize size;
  final int quantity;
  final Color color;
  final double fem; // Added fem for responsiveness

  const QuantityIcon({
    Key? key,
    required this.size,
    required this.quantity,
    required this.color,
    this.fem = 1.0, // Default scaling factor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the size dimensions based on the IconSize enum
    double width;
    double height;
    double fontSize;

    switch (size) {
      case IconSize.extraSmall:
        width = 18.0 * fem; // 18 pixels width
        height = 18.0 * fem; // 18 pixels height
        fontSize = 10.0 * fem; // Adjust font size accordingly
        break;

      case IconSize.small:
        width = 20.0 * fem;
        height = 20.0 * fem;
        fontSize = 12.0 * fem;
        break;

      case IconSize.normal:
      default:
        width = 24.0 * fem;
        height = 24.0 * fem;
        fontSize = 14.0 * fem;
        break;
    }

    // Optional: Limit the displayed quantity (e.g., "99+")
    String displayQuantity = quantity > 99 ? '99+' : '$quantity';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle, // Perfect circular shape
      ),
      child: Center(
        child: Text(
          displayQuantity,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
