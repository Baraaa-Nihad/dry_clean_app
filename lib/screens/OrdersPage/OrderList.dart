import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Cards/OrderCard.dart';
import 'package:saleem_dry_clean/components/EmptyPage/EmptyPage.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class OrderList extends StatelessWidget {
  final List<OrderData> orders;
  final ScrollController scrollController;
  final bool isLoadingItems;
  final bool isLoadingMore;
  final bool isLoadingOrders;
  final Future<void> Function() onRefresh;
  final bool isCompleted;
  final bool isUserSignedIn;

  const OrderList({
    Key? key,
    required this.orders,
    required this.scrollController,
    required this.isLoadingItems,
    required this.isLoadingMore,
    required this.isLoadingOrders,
    required this.onRefresh,
    required this.isCompleted,
    required this.isUserSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Check if the user is not signed in
    if (!isUserSignedIn) {
      return EmptyPage(
        fem: 1,
        iconUrl: 'assets/Icons/EmptyBasketIcon.svg',
        title: localizations.translate("Sign In Required"),
        subtitle:
            localizations.translate("Please sign in to view your orders."),
        showButton: true,
        buttonAction: () =>
            Provider.of<NavigationProvider>(context, listen: false)
                .setSelectedIndex(0),
        buttonText: localizations.translate("Sign In Now"),
        enableRefresh: true,
      );
    }

    // Check if there are no orders and the orders are not loading
    if (orders.isEmpty && !isLoadingOrders) {
      return EmptyPage(
        fem: 1,
        iconUrl: 'assets/Icons/EmptyBasketIcon.svg',
        title: isCompleted
            ? localizations.translate("no_completed_orders")
            : localizations.translate("no_current_orders"),
        subtitle: isCompleted
            ? localizations.translate("schedule_laundry_service")
            : localizations.translate("no_current_laundry_orders"),
        showButton: false,
        enableRefresh: true,
      );
    }

    // If there are orders or if orders are still loading, show the list
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.white,
      color: AppColors.gray70,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount:
            isLoadingOrders ? 3 : orders.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show shimmer when loading orders
          if (isLoadingOrders || index >= orders.length) {
            return const OrderCard(isLoadingItems: true, isOrderLoading: true);
          } else {
            return OrderCard(
              order: orders[index],
              isLoadingItems: isLoadingItems,
              isOrderLoading: false,
            );
          }
        },
      ),
    );
  }
}
