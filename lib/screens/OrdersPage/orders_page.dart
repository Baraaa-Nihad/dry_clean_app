import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/Cards/OrderCard.dart';
import 'package:saleem_dry_clean/components/CustomRefreshIndicator/CustomRefreshIndicator.dart';
import 'package:saleem_dry_clean/components/Notification/NotificationButton.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/OrderTabBar.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/components/EmptyPage/EmptyPage.dart'; // Ensure this import is present
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class OrdersPage extends StatefulWidget {
  final double fem;

  const OrdersPage({
    Key? key,
    required this.fem,
  }) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollController _scrollControllerCompleted;

  bool _isLoadingMore = false;
  bool _isLoadingMoreCompleted = false;
  bool _isShimmering = true;
  bool _isShimmeringCompleted = true; // Flag for shimmer in completed orders
  bool _isCompletedOrdersLoaded = false; // Track completed orders load

  // FCM subscription — refreshes active orders when a push notification
  // arrives while the screen is open (e.g. admin changed an order status).
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Start shimmer effect immediately when the page opens
    _isShimmering = true;
    _isShimmeringCompleted = true; // Start completed shimmer as well

    // Refresh active orders whenever an FCM message arrives in the foreground.
    // This covers the case where the admin changes a status and the user is
    // already on this screen — without this the badge stayed stale until
    // the user manually pull-to-refreshed.
    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) {
      if (mounted) _refreshOrders();
    });

    // Fetch orders after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Ensure widget is still mounted
        _fetchOrders();
      }
    });
  }

  void _initializeControllers() {
    _tabController = TabController(length: 2, vsync: this);

    _scrollController = ScrollController()..addListener(_onScroll);
    _scrollControllerCompleted = ScrollController()
      ..addListener(_onScrollCompleted);

    _tabController.addListener(() {
      if (_tabController.index == 1 && !_isCompletedOrdersLoaded) {
        if (mounted) {
          // Ensure widget is still mounted before refreshing orders
          _refreshCompletedOrders();
        }
        _isCompletedOrdersLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    // Dispose controllers and remove listeners
    _tabController.dispose();
    _scrollController.removeListener(_onScroll); // Remove listeners
    _scrollController.dispose();
    _scrollControllerCompleted
        .removeListener(_onScrollCompleted); // Remove listeners
    _scrollControllerCompleted.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    // Clear previous orders and start fresh
    await _clearOrdersData();
    await _refreshOrders();

    if (mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.orders.isNotEmpty ||
          userProvider.completedOrders.isNotEmpty) {
        setState(() {
          _isShimmering = false;
          _isShimmeringCompleted = false;
        });
      }
    }
  }

  Future<void> _clearOrdersData() async {
    setState(() {
      _isShimmering = true;
    });
    Provider.of<UserProvider>(context, listen: false).clearOrdersData();
  }

  Future<void> _refreshOrders() async {
    final lang = AppLocalizations.of(context).locale.languageCode;

    if (mounted) {
      setState(() {
        _isShimmering = true;
        _isLoadingMore = false;
      });
    }

    await Provider.of<UserProvider>(context, listen: false)
        .fetchOrders(lang: lang, context: context);

    if (mounted) {
      setState(() {
        _isShimmering = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshCompletedOrders() async {
    final lang = AppLocalizations.of(context).locale.languageCode;

    if (mounted) {
      setState(() {
        _isShimmeringCompleted = true;
        _isLoadingMoreCompleted = false;
      });
    }

    await Provider.of<UserProvider>(context, listen: false)
        .fetchCompletedOrders(lang: lang, context: context);

    if (mounted) {
      setState(() {
        _isShimmeringCompleted = false;
        _isLoadingMoreCompleted = false;
      });
    }
  }

  void _onScroll() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_scrollController.position.extentAfter < 100 &&
        !_isLoadingMore &&
        userProvider.hasMoreOrders) {
      setState(() => _isLoadingMore = true);
      final lang = AppLocalizations.of(context).locale.languageCode;
      userProvider.loadMoreOrders(lang: lang, context: context).then((_) {
        if (mounted) {
          setState(() => _isLoadingMore = false);
        }
      });
    }
  }

  void _onScrollCompleted() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_scrollControllerCompleted.position.extentAfter < 100 &&
        !_isLoadingMoreCompleted &&
        userProvider.hasMoreCompletedOrders) {
      setState(() => _isLoadingMoreCompleted = true);
      final lang = AppLocalizations.of(context).locale.languageCode;
      userProvider.loadMoreOrders(
          fetchCompleted: true, lang: lang, context: context);
      if (mounted) {
        setState(() => _isLoadingMoreCompleted = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppHeader(
        quantityNumber: true,
        title: localizations.translate('orders'),
        fem: widget.fem,
        suffixIcon: NotificationButton(),
      ),
      body: userProvider.isLoading
          ? _buildGlobalShimmer()
          : !userProvider.userSignedIn
              ? _buildNotSignedInView(localizations)
              : Column(
                  children: [
                    OrderTabBar(
                      fem: widget.fem,
                      tabController: _tabController,
                      hasOrders: userProvider.orders.isNotEmpty ||
                          userProvider.completedOrders.isNotEmpty,
                      onRefresh: _refreshOrders,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(
                            userProvider.orders,
                            _scrollController,
                            isCompleted: false,
                            isShimmering: _isShimmering,
                            hasMore: userProvider.hasMoreOrders,
                          ),
                          _buildOrderList(
                            userProvider.completedOrders,
                            _scrollControllerCompleted,
                            isCompleted: true,
                            isShimmering: _isShimmeringCompleted,
                            hasMore: userProvider.hasMoreCompletedOrders,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGlobalShimmer() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(left: 24, right: 25, top: 20),
          child: ShimmerLoadingOrderCard(),
        );
      },
    );
  }

  Widget _buildNotSignedInView(AppLocalizations localizations) {
    return CustomRefreshIndicator(
      onRefresh: () async {},
      child: EmptyPage(
        fem: 1,
        iconUrl: 'assets/Icons/EmptyBasketIcon.svg',
        title: localizations.translate("sign_in_required"),
        subtitle: localizations.translate("please_sign_in_to_view_your_order"),
        enableRefresh: true,
      ),
    );
  }

  Widget _buildOrderList(
    List<OrderData> orders,
    ScrollController controller, {
    required bool isCompleted,
    required bool isShimmering,
    required bool hasMore,
  }) {
    final localizations = AppLocalizations.of(context);

    if (isShimmering) {
      return _buildShimmerList(3);
    }

    if (orders.isEmpty && !isShimmering) {
      return CustomRefreshIndicator(
        onRefresh: isCompleted ? _refreshCompletedOrders : _refreshOrders,
        child: EmptyPage(
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
        ),
      );
    }

    return CustomRefreshIndicator(
      onRefresh: isCompleted ? _refreshCompletedOrders : _refreshOrders,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: orders.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Padding(
              padding: EdgeInsets.only(left: 24, right: 25, top: 20),
              child: ShimmerLoadingOrderCard(),
            );
          }
          return Padding(
            padding: EdgeInsets.only(left: 24, right: 25, top: 20),
            child: OrderCard(
              order: orders[index],
              isLoadingItems: false,
              isOrderLoading: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList(int count) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(left: 24, right: 25, top: 20),
          child: ShimmerLoadingOrderCard(),
        );
      },
    );
  }
}

class ShimmerLoadingOrderCard extends StatelessWidget {
  const ShimmerLoadingOrderCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OrderCard(isLoadingItems: true, isOrderLoading: true);
  }
}
