// lib/screens/MainNavigation/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/BottomNav/BottomNavItem.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/NoInternetModalContent/no_internet_modal_content.dart';
import 'package:saleem_dry_clean/components/connectivityBanner/connectivity_banner.dart';
import 'package:saleem_dry_clean/screens/BasketPage/basket_page.dart';
import 'package:saleem_dry_clean/screens/HomeScreen/home_screen.dart';
import 'package:saleem_dry_clean/screens/MorePage/more_page.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/orders_page.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/connectivity_service.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _isModalVisible = false; // To track modal visibility

  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    // Set the initial index based on the passed parameter
    Provider.of<NavigationProvider>(context, listen: false)
        .setSelectedIndex(widget.initialIndex);

    // Initialize connectivity service
    _connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    // Add listener to connectivity changes
    _connectivityService.addListener(_connectivityListener);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _connectivityService.removeListener(_connectivityListener);
    super.dispose();
  }

  void _connectivityListener() {
    if (!_connectivityService.isConnected && !_isModalVisible) {
      BlankModal.show(
        context,
        1,
        NoInternetModalContent(
          fem: 1,
          onRetry: _handleRetry,
        ),
        isDismissible: false,
      );
      _isModalVisible = true;
    } else if (_connectivityService.isConnected && _isModalVisible) {
      Navigator.of(context, rootNavigator: true).pop(); // Close the modal
      _isModalVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final navigationProvider = Provider.of<NavigationProvider>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    final TextDirection textDirection = Directionality.of(context);
    final double fem = 1.0; // Adjust as per your design scaling
    final double itemWidth = MediaQuery.of(context).size.width / 4;
    final double _indicatorPosition =
        navigationProvider.selectedIndex * itemWidth;

    final List<Widget> _pages = [
      HomeScreen(
        fem: fem,
      ),
      BasketPage(
        fem: fem,
      ),
      OrdersPage(
        key: const PageStorageKey('OrdersPage'),
        fem: fem,
      ),
      MorePage(
        fem: fem,
      ),
    ];

    // تم تغليف الـ Scaffold بـ SafeArea (مع تفعيل الجزء السفلي فقط حفاظاً على الهيدر العلوي في الصفحات)
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            _pages[navigationProvider.selectedIndex],
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ConnectivityBanner(),
            ),
          ],
        ),
        bottomNavigationBar: Stack(
          children: [
            Container(
              // تم إلغاء الارتفاع المقيد الثابت ليعمل بشكل ديناميكي مرن ومريح
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    offset: Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BottomNavItem(
                    filledIconPath: 'assets/Icons/HomeFilled.svg',
                    iconPath: 'assets/Icons/Home.svg',
                    label: localizations?.translate('home') ?? 'Home',
                    isActive: navigationProvider.selectedIndex == 0,
                    onTap: () => navigationProvider.navigateToHome(),
                  ),
                  BottomNavItem(
                    filledIconPath: 'assets/Icons/BasketFilled.svg',
                    iconPath: 'assets/Icons/Basket.svg',
                    label: localizations?.translate('basket') ?? 'Basket',
                    isActive: navigationProvider.selectedIndex == 1,
                    onTap: () => navigationProvider.navigateToBasket(),
                  ),
                  BottomNavItem(
                    filledIconPath: 'assets/Icons/OrdersFilled.svg',
                    iconPath: 'assets/Icons/Orders.svg',
                    label: localizations?.translate('orders') ?? 'Orders',
                    isActive: navigationProvider.selectedIndex == 2,
                    onTap: () => navigationProvider.navigateToOrders(),
                  ),
                  BottomNavItem(
                    filledIconPath: 'assets/Icons/MoreFilled.svg',
                    iconPath: 'assets/Icons/More.svg',
                    label: localizations?.translate('more') ?? 'More',
                    isActive: navigationProvider.selectedIndex == 3,
                    onTap: () => navigationProvider.navigateToMore(),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: textDirection == TextDirection.ltr
                  ? _indicatorPosition + itemWidth / 2 - (6.55.w / 2)
                  : MediaQuery.of(context).size.width -
                      (_indicatorPosition + itemWidth / 2 + (6.55.w / 2)),
              top: 0.h,
              child: SvgPicture.asset(
                'assets/Icons/Union.svg',
                width: 6.55.w,
                height: 6.83.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle the Retry button press
  Future<void> _handleRetry() async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    if (!connectivityService.isConnected) {
      print('RetryHandler: No internet connection. Cannot retry.');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      print('RetryHandler: Attempting to refresh user data');
      await userProvider.refreshUserData(context);
      print('RetryHandler: User data refreshed');

      if (connectivityService.isConnected && _isModalVisible) {
        Navigator.of(context, rootNavigator: true).pop(); // Close the modal
        _isModalVisible = false;
        print('RetryHandler: Modal dismissed after successful retry');
      }
    } catch (e) {
      print('RetryHandler: Retry failed with error: $e');
    }
  }
}
