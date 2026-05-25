// lib/screens/NotificationPage/notification_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/NotificationCard.dart';
import 'package:saleem_dry_clean/components/CustomRefreshIndicator/CustomRefreshIndicator.dart';
import 'package:saleem_dry_clean/components/EmptyPage/EmptyPage.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/notification_provider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class NotificationPage extends StatelessWidget {
  final double fem;
  // Check the current text direction
  const NotificationPage({
    Key? key,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppHeader(
          quantityNumber: true,
          title: localizations?.translate('notifications') ?? 'Notifications',
          fem: fem,
          prefixIcon: BackButtonWidget(
            onTap: () {
              Navigator.pop(context);
            },
          ),
          onPrefixIconTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.white,
        body: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (!notificationProvider.isInitialized) {
              // If you still have an initialization step, you can keep this
              return Center(
                child: LoadingDots(
                  fem: 1,
                ), // Replace with your loading widget
              );
            }

            if (notificationProvider.notifications.isEmpty) {
              return EmptyPage(
                fem: fem,
                backgroundColor: AppColors.white,
                iconUrl: 'assets/Icons/Notifications.svg',
                title: localizations
                        ?.translate("notifications_empty_screen_title") ??
                    'No Notifications',
                subtitle: localizations
                        ?.translate("notifications_empty_screen_subtitle") ??
                    'You have no notifications at the moment.',
                showButton: false,
              );
            } else {
              return CustomRefreshIndicator(
                onRefresh: () async {
                  // Implement pull-to-refresh functionality if needed
                  // For example, fetch new notifications from an API
                  // await notificationProvider.fetchNotifications();
                },
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24 * fem, vertical: 16 * fem),
                  itemCount: notificationProvider.notifications.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 12 * fem),
                  itemBuilder: (context, index) {
                    final notification =
                        notificationProvider.notifications[index];
                    print(notificationProvider.notifications.length);
                    return NotificationCard(
                      notification: notification,
                      onTap: () {
                        // Handle notification tap, e.g., navigate to order details
                        // Optionally mark as read
                        if (notification.isNew) {
                          notificationProvider.markAsRead(index);
                        }
                      },
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Remove any methods related to deleting notifications if not needed
}
