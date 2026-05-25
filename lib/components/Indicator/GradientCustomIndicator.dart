// lib/components/Indicator/GradientCustomIndicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class GradientCustomIndicator extends StatelessWidget {
  final int activeIndex;
  final int count;
  final double fem;

  const GradientCustomIndicator({
    Key? key,
    required this.activeIndex,
    required this.count,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine text direction (LTR or RTL)
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the dots horizontally
      children: List.generate(count, (index) {
        Widget dot;

        if (index < activeIndex) {
          // **1. Previous Dots: ActivitedDot.svg**
          dot = SvgPicture.asset(
            'assets/Icons/ActivitedDot.svg',
            width: 10 * fem,
            height: 10 * fem,
            semanticsLabel: 'Completed Step ${index + 1}',
          );
        } else if (index == activeIndex) {
          // **2. Current Dot: gradientDot.svg**
          dot = SvgPicture.asset(
            'assets/Icons/gradientDot.svg',
            width: 10 * fem,
            height: 10 * fem,
            semanticsLabel: 'Current Step ${index + 1}',
          );
        } else {
          // **3. Next Dots: Gray Inactive Circles**
          dot = Container(
            width: 10 * fem,
            height: 10 * fem,
            decoration: BoxDecoration(
              color: AppColors.gray20, // Gray color for inactive dots
              shape: BoxShape.circle,
            ),
            // Optional: Add semantics for accessibility
            // If you want screen readers to announce them as upcoming steps
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 2.5 * fem), // Spacing between dots
          child: dot,
        );
      }),
    );
  }
}
