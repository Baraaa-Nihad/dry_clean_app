// lib/widgets/notification_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:saleem_dry_clean/screens/NotificationPage/NotificationModel.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'dart:ui' as ui;

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Determine if the current text direction is RTL
    bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    final formattedDate =
        DateFormat('MM-dd hh:mm a').format(notification.dateTime);

    // Determine the icon based on the notification's new status
    final String iconPath = notification.isNew
        ? 'assets/Icons/bill_Icon_new.svg'
        : 'assets/Icons/bill_Icon.svg';
    final Color backgroundColor =
        notification.isNew ? AppColors.gray10 : AppColors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: const Color(0xFFE5EAF6), width: 1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to top
          textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          children: [
            // Display the appropriate icon based on the notification status
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate(
                      'order_status',
                      params: {
                        'orderNumber': notification.orderNumber,
                        'status': notification.status,
                      },
                    ),
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: AppColors.gray70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: AppColors.gray50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
