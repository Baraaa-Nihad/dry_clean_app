// lib/components/Buttons/BasketAppBarIcon.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Notification/QuantityIcon.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart'; // Import OrderProvider

class BasketAppBarIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  const BasketAppBarIcon({
    Key? key,
    this.onTap,
    this.size = 80.0, // Default size set to 48.0
    this.color, // Optional color override
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the current text direction is RTL
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, // Allows the badge to overflow if necessary
        children: [
          // Basket Icon
          SvgPicture.asset(
            'assets/Icons/basketAppBarIcon.svg',
            width: size.w, // Responsive width
            height: size.h, // Responsive height

            fit: BoxFit.contain,
            semanticsLabel: 'Basket', // Accessibility label
          ),
          // Badge
          Selector<OrderProvider, int>(
            selector: (_, provider) => provider.totalQuantity,
            builder: (_, quantity, __) {
              if (quantity <= 0)
                return SizedBox.shrink(); // No badge if quantity is 0
              return Positioned(
                // Position based on text direction
                top: 20.h, // Slightly above the top edge
                right: isRtl ? null : 20.w, // Top-right for LTR
                left: isRtl ? 20.w : null, // Top-left for RTL
                child: QuantityIcon(
                  size: IconSize.small, // Adjust size as needed
                  quantity: quantity,
                  color: AppColors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
