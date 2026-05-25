// lib/components/Notification/NotificationButton.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Notification/QuantityIcon.dart';
import 'package:saleem_dry_clean/services/Providers/notification_provider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class NotificationButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final String assetPath;

  const NotificationButton({
    Key? key,
    this.onTap,
    this.backgroundColor,
    this.assetPath = 'assets/vectors/notifications.svg', // Default asset path
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    double fem = MediaQuery.of(context).size.width / 375; // Responsive sizing

    // Load the SVG asset outside Consumer to avoid redundant rebuilds
    final notificationIcon = SvgPicture.asset(
      assetPath,
      width: 80 * fem,
      height: 80 * fem,
    );

    return GestureDetector(
      onTap: onTap ??
          () {
            // Navigate to NotificationPage if onTap is not provided
            Navigator.pushNamed(context, RouteNames.notifications);
          },
      child: Semantics(
        label: 'Notification Button with notifications',
        child: Container(
          width: 80 * fem,
          height: 80 * fem,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Center the notification icon
              Center(child: notificationIcon),

              // Use Consumer to update only the badge part
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  // if (!notificationProvider.isInitialized) {
                  //   return QuantityIcon(
                  //     size: IconSize.extraSmall,
                  //     quantity: 0,
                  //     color: AppColors.red,
                  //   ); // Display a loading indicator while initializing
                  // }
                  int quantity = notificationProvider.notificationCount;

                  if (quantity <= 0) return SizedBox.shrink();

                  return Positioned(
                    top: 10 * fem,
                    right: isRtl ? null : 20 * fem,
                    left: isRtl ? 20 * fem : null,
                    child: QuantityIcon(
                      size: IconSize.extraSmall,
                      quantity: quantity,
                      color: AppColors.red,
                      fem: fem,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
