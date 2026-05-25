// lib/components/Buttons/BackButtonWidget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double size; // Base size for the icon

  const BackButtonWidget({
    Key? key,
    required this.onTap,
    this.size = 80.0, // Default size, can be overridden
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the current text direction
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // Select the appropriate SVG based on text direction
    String iconPath = isRtl
        ? 'assets/vectors/backRightGradientArrow.svg'
        : 'assets/vectors/backLeftGradientArrow.svg';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size, // Responsive width
        height: size, // Responsive height
        child: SvgPicture.asset(
          iconPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
