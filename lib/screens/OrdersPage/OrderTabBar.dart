import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/components/Indicator/CustomTabIndicator.dart';

class OrderTabBar extends StatelessWidget {
  final double fem;
  final TabController tabController;
  final bool hasOrders;
  final Future<void> Function() onRefresh; // Function to refresh

  const OrderTabBar({
    Key? key,
    required this.fem,
    required this.tabController,
    required this.hasOrders,
    required this.onRefresh, // Pass the refresh callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
        width: 428 * fem,
        height: 44 * fem,
        decoration: BoxDecoration(color: AppColors.white),
        child: TabBar(
          controller: tabController,
          dividerColor: AppColors.gray20,
          indicator: CustomTabIndicator(),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColors.gray80,
          labelStyle: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              height: 0,
            ),
          ),
          unselectedLabelColor: AppColors.gray50,
          unselectedLabelStyle: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              height: 0,
            ),
          ),
          tabs: [
            Tab(text: localizations.translate('current')),
            Tab(text: localizations.translate('completed')),
          ],
        ));
  }
}
