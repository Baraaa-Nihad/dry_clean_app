// lib/pages/service_page.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/AppBar/BasketAppBarIcon.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/NoResultsComponent.dart';
import 'package:saleem_dry_clean/components/EmptyPage/SystemEmptyPage.dart';
import 'package:saleem_dry_clean/components/Filters/CategoryFilter.dart';
import 'package:saleem_dry_clean/components/Items/CategoryCard.dart';
import 'package:saleem_dry_clean/components/SearchBar/customSearchBar.dart';
import 'package:saleem_dry_clean/services/Models/Group.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/ServiceTypeProvider.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/utils/throttle.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:saleem_dry_clean/services/navigator/navigator_service.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/KeyboardUtils/KeyboardUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';

class ServicePage extends StatefulWidget {
  final String serviceName;
  final String generalUnit;
  final String serviceTypeId;
  final String pricePerUnit;

  const ServicePage({
    Key? key,
    required this.serviceName,
    required this.generalUnit,
    required this.pricePerUnit,
    required this.serviceTypeId,
  }) : super(key: key);

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _isScrolled = false;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  bool _isNavigating = false;
  bool _isSearch = false;
  int selectedIndex = -1;

  Timer? _debounce; // For debouncing scroll events
  bool _isInitialLoad = true; // Flag to indicate initial load
  bool _isProgrammaticallyScrolling = false; // Flag to prevent recursion
  final Throttle _throttle = Throttle(milliseconds: 16); // Throttle of ~60fps

  // ScrollController for CategoryFilter
  final ScrollController _categoryScrollController = ScrollController();

  // Flag to track if the bottom has been reached
  bool _hasScrolledToBottom = false;

  // Variables to manage visibility
  bool _showAppHeader = true;
  bool _showCategoryFilter = false;
  double _previousScrollOffset = 0.0;
  final double _scrollThreshold =
      10.0; // Increased threshold to prevent accidental triggers

  @override
  void initState() {
    super.initState();

    // Fetch data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceTypeProvider =
          Provider.of<ServiceTypeProvider>(context, listen: false);
      serviceTypeProvider.fetchServiceTypes(widget.serviceTypeId).then((_) {
        // After fetching, prefetch images
        _prefetchImages(serviceTypeProvider.groups);

        // Guard against calling setState on a disposed widget (e.g. the user
        // navigated away while the fetch was still in flight).
        if (!mounted) return;

        setState(() {
          _isInitialLoad = false;
          if (serviceTypeProvider.categories.isNotEmpty) {
            selectedIndex = 0;
          }
        });
      });
    });

    // Listen to scroll positions to adjust header size and update selected category
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  /// Scroll Listener with Throttle
  /// Scroll Listener with Throttle
  void _onScroll() {
    _throttle.run(() {
      if (!mounted) return; // Guard: widget may have been disposed
      if (_isInitialLoad || _isProgrammaticallyScrolling) return;

      _updateSelectedCategory();

      // Check if the user has scrolled to the bottom
      _checkIfScrolledToBottom();

      // Determine scroll direction to update _isScrolled
      final visibleItems = _itemPositionsListener.itemPositions.value;

      if (visibleItems.isNotEmpty) {
        int firstVisibleIndex = visibleItems
            .where((item) => item.itemTrailingEdge > 0)
            .map((item) => item.index)
            .reduce((value, element) => value < element ? value : element);

        if (firstVisibleIndex > 1) {
          if (!_isScrolled) {
            setState(() {
              _isScrolled = true;
            });
          }
        } else {
          if (_isScrolled) {
            setState(() {
              _isScrolled = false;
            });
          }
        }
      }
    });
  }

  /// Update selected category based on the closest group to the center
  void _updateSelectedCategory() {
    // Only update if CategoryFilter is visible
    if (!_showCategoryFilter) return;

    final serviceTypeProvider =
        Provider.of<ServiceTypeProvider>(context, listen: false);
    final positions = _itemPositionsListener.itemPositions.value;

    if (positions.isNotEmpty) {
      double minDistance = double.infinity;
      Group? closestGroup;

      for (final position in positions) {
        // Calculate the item's center relative to the viewport
        double itemCenter =
            (position.itemLeadingEdge + position.itemTrailingEdge) / 2;
        double distanceFromCenter =
            (itemCenter - 0.5).abs(); // 0.5 represents the center

        if (distanceFromCenter < minDistance) {
          minDistance = distanceFromCenter;
          int groupIndex =
              position.index - 1; // Adjust for SearchBar at index 0
          if (groupIndex >= 0 &&
              groupIndex < (serviceTypeProvider.groups?.length ?? 0)) {
            closestGroup = serviceTypeProvider.groups![groupIndex];
          }
        }
      }

      if (closestGroup != null) {
        // Find the index of the category corresponding to the closest group
        int categoryIndex = serviceTypeProvider.categories.indexWhere(
          (category) => category['id'] == closestGroup?.groupId,
        );

        if (categoryIndex != -1 && categoryIndex != selectedIndex) {
          setState(() {
            selectedIndex = categoryIndex;
          });

          // Trigger haptic feedback
          HapticFeedback.lightImpact();

          _scrollToCategory(categoryIndex); // Scroll to the selected category
        }
      }
    }
  }

  /// Check if the user has scrolled to the bottom of the main list
  void _checkIfScrolledToBottom() {
    final serviceTypeProvider =
        Provider.of<ServiceTypeProvider>(context, listen: false);
    final totalItems = serviceTypeProvider.groups?.length ?? 0;
    final visibleItems = _itemPositionsListener.itemPositions.value;

    // Determine if the last item is visible
    bool isLastItemVisible =
        visibleItems.any((item) => item.index == totalItems);

    if (isLastItemVisible && !_hasScrolledToBottom) {
      _hasScrolledToBottom = true;
      _scrollCategoryToEnd();
    } else if (!isLastItemVisible && _hasScrolledToBottom) {
      _hasScrolledToBottom = false;
    }
  }

  /// Scroll the CategoryFilter to the end to show the last category
  void _scrollCategoryToEnd() {
    if (!_categoryScrollController.hasClients) {
      // Schedule the scroll to occur after the first frame when the controller is attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_categoryScrollController.hasClients) {
          _categoryScrollController.animateTo(
            _categoryScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          debugPrint(
              'ScrollController still has no clients after post frame callback.');
        }
      });
    } else {
      _categoryScrollController.animateTo(
        _categoryScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Prefetch images to reduce loading times during scrolling
  void _prefetchImages(List<Group>? groups) {
    if (groups == null) return;

    for (var group in groups) {
      for (var product in group.products) {
        final resolvedPath = Config.resolveImageUrl(product.imagePath);
        final lowerPath = resolvedPath.toLowerCase();
        final isNetworkImage =
            lowerPath.startsWith('http://') || lowerPath.startsWith('https://');
        final isSvg = lowerPath.endsWith('.svg') || lowerPath.contains('.svg?');

        if (isNetworkImage && !isSvg) {
          precacheImage(
            CachedNetworkImageProvider(resolvedPath),
            context,
            onError: (exception, stackTrace) {
              debugPrint('Failed to prefetch image $resolvedPath: $exception');
            },
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _throttle.cancel(); // Cancel the throttle timer

    _debounce?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    _focusScopeNode.dispose();
    _categoryScrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  /// Scroll to the selected category to ensure it is visible
  void _scrollToCategory(int index) {
    // Only proceed if CategoryFilter is visible and ScrollController has clients
    if (!_showCategoryFilter || !_categoryScrollController.hasClients) {
      return;
    }

    // Assume each category item has a fixed width, e.g., 100 * fem + margin
    // Adjust this value based on your actual item width
    final double itemWidth =
        100 * ScreenUtil().scaleWidth + 8 * ScreenUtil().scaleWidth;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetOffset =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    // Ensure the offset is within the scrollable range
    double maxScroll = _categoryScrollController.position.maxScrollExtent;
    double minScroll = _categoryScrollController.position.minScrollExtent;
    double finalOffset = targetOffset.clamp(minScroll, maxScroll);

    // Perform the scroll safely
    if (_categoryScrollController.hasClients) {
      _categoryScrollController.animateTo(
        finalOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Schedule the scroll after the first frame when the controller is attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_categoryScrollController.hasClients) {
          _categoryScrollController.animateTo(
            finalOffset,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          debugPrint(
              'ScrollController still has no clients when attempting to scroll to category.');
        }
      });
    }
  }

  /// Scroll to the selected group when a category is selected
  void scrollToSelectedCard(int index) {
    final serviceTypeProvider =
        Provider.of<ServiceTypeProvider>(context, listen: false);
    final category = serviceTypeProvider.categories[index];
    final groupIndex = serviceTypeProvider.groups!
        .indexWhere((group) => group.groupId == category['id']);

    if (groupIndex != -1) {
      _isProgrammaticallyScrolling = true; // Prevent recursion
      _itemScrollController
          .scrollTo(
        index: groupIndex + 1, // +1 to account for the SearchBar at index 0
        duration: Duration(milliseconds: 300), // Faster scroll duration
        curve: Curves.easeInOutCubic, // Smoother curve
      )
          .then((_) {
        _isProgrammaticallyScrolling = false; // Reset flag after scrolling
      }).catchError((error) {
        debugPrint('Error during programmatic scroll: $error');
        _isProgrammaticallyScrolling = false;
      });

      _scrollToCategory(index); // Ensure the selected category is visible
    }
  }

  /// Build the shimmer effect with detailed elements
  Widget buildShimmerEffect(double fem) {
    return Column(
      children: List.generate(3, (index) => buildShimmerCard(fem)),
    );
  }

  /// Single shimmer card layout with detailed shimmer elements
  Widget buildShimmerCard(double fem) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * fem, horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * fem),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer for Title
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 20 * fem,
                end: 20 * fem,
                top: 8 * fem,
              ),
              child: Shimmer.fromColors(
                baseColor: AppColors.gray20,
                highlightColor: AppColors.gray10,
                child: Container(
                  height: 20 * fem,
                  width: 150 * fem, // Simulate title width
                  color: AppColors.gray20,
                ),
              ),
            ),
            SizedBox(height: 12 * fem),
            Divider(
              color: AppColors.gray20,
              thickness: 0.5,
              height: 0.5,
            ),
            // Shimmer for Content
            Padding(
              padding: EdgeInsets.all(16 * fem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (i) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8 * fem),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: AppColors.gray20,
                              highlightColor: AppColors.gray10,
                              child: Container(
                                width: 48 * fem,
                                height: 48 * fem,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12 * fem),
                                  color: AppColors.gray20,
                                ),
                              ),
                            ),
                            SizedBox(width: 16 * fem),
                            Expanded(
                              child: Shimmer.fromColors(
                                baseColor: AppColors.gray20,
                                highlightColor: AppColors.gray10,
                                child: Container(
                                  height: 20 * fem,
                                  color: AppColors.gray20,
                                ),
                              ),
                            ),
                            SizedBox(width: 16 * fem),
                          ],
                        ),
                      ),
                      if (i != 2)
                        Container(
                          margin: EdgeInsets.only(left: 64 * fem),
                          child: Divider(
                            color: AppColors.gray20,
                            thickness: 0.5,
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle search status changes
  void _handleSearchStatusChanged(bool isSearch) {
    setState(() {
      _isSearch = isSearch;
    });
  }

  /// Handle back navigation with focus and keyboard handling
  Future<void> _handleBackNavigation() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      // Trigger haptic feedback
      HapticFeedback.lightImpact();

      // Optionally, unfocus any focused widgets and dismiss the keyboard
      FocusScope.of(context).unfocus();
      dismissKeyboard(context);

      // Perform the pop after a short delay to allow for any UI updates
      await Future.delayed(Duration(milliseconds: 100));

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      debugPrint('Error during back navigation: $error');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while navigating back.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  /// Handle basket tap with navigation
  Future<void> _handleBasketTap(BuildContext context) async {
    await _handleBackNavigation();
    NavigatorService.navigateToAndRemoveUntil(RouteNames.main);
    // navigateToAndRemoveUntil disposes this widget — capture the provider
    // reference NOW before the delayed callback fires on a dead context.
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    Future.delayed(Duration(milliseconds: 100), () {
      navigationProvider.setSelectedIndex(1);
      // Widget is disposed after navigateToAndRemoveUntil — do not call setState.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    // Note: It's recommended to initialize ScreenUtil at a higher level (e.g., main.dart)
    ScreenUtil.init(
      context,
      designSize: Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    double fem = ScreenUtil().scaleWidth;
    final localizations = AppLocalizations.of(context);
    final TextDirection textDirection = Directionality.of(context);

    // Define conditional padding based on language direction and CategoryFilter visibility
    EdgeInsets conditionalPadding = _showCategoryFilter
        ? (textDirection == TextDirection.ltr
            ? EdgeInsets.only(
                left: _isScrolled ? 0.w : 24.w,
                top: !_showAppHeader ? 60.h : 0.h,
                bottom: 0.h,
              )
            : EdgeInsets.only(
                right: _isScrolled ? 0.w : 24.w,
                top: !_showAppHeader ? 60.h : 0.h,
                bottom: 0.h,
              ))
        : EdgeInsets.only(
            top: 0.h,
            bottom: 20.h,
          );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        dismissKeyboard(context);
      },
      child: FocusScope(
        node: _focusScopeNode,
        child: Scaffold(
          backgroundColor: AppColors.gray10,
          body: Column(
            children: [
              // Animated AppHeader with Smooth Animation
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _showAppHeader ? 120.h : 0, // Animate height
                color: AppColors.white, // Background color
                child: AnimatedOpacity(
                  opacity: _showAppHeader ? 1.0 : 0.0, // Animate opacity
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut, // Apply ease-out curve
                  child: _showAppHeader
                      ? AppHeader(
                          quantityNumber: false,
                          title: widget.serviceName,
                          prefixIcon: BackButtonWidget(
                            onTap: _handleBackNavigation,
                          ),
                          suffixIcon: BasketAppBarIcon(),
                          onPrefixIconTap: _handleBackNavigation,
                          onSuffixIconTap: () => _handleBasketTap(context),
                          fem: fem,
                        )
                      : SizedBox.shrink(), // Keeps the widget in the tree
                ),
              ),

              // Animated Category Filter with Conditional Padding and Smooth Animation
              AnimatedPadding(
                duration: Duration(milliseconds: 300),
                padding: conditionalPadding,
                curve: Curves.easeOut, // Apply ease-out curve
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: _showCategoryFilter ? 1.0 : 0.0,
                  curve: Curves.easeOut, // Apply ease-out curve
                  child: Visibility(
                    visible: _showCategoryFilter,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: false,
                    child: Consumer<ServiceTypeProvider>(
                      builder: (context, serviceTypeProvider, child) {
                        final categories = serviceTypeProvider.categories;
                        final isLoadingCategories =
                            serviceTypeProvider.isLoadingCategories;

                        if (isLoadingCategories) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 20.h),
                            child: Shimmer.fromColors(
                              baseColor: AppColors.gray20,
                              highlightColor: AppColors.gray10,
                              child: Container(
                                height: 44 * fem,
                                color: AppColors.gray20,
                              ),
                            ),
                          );
                        }

                        if (categories.isEmpty) {
                          return SizedBox.shrink();
                        }

                        return Container(
                          color: _showAppHeader
                              ? AppColors.white
                              : AppColors.gray10,
                          child: CategoryFilter(
                            isLoading: isLoadingCategories,
                            items: categories,
                            fem: fem,
                            selectedIndex: selectedIndex,
                            scrollController: _categoryScrollController,
                            onItemSelected: (index) {
                              if (selectedIndex != index) {
                                setState(() {
                                  selectedIndex = index;
                                });

                                // Trigger haptic feedback
                                HapticFeedback.lightImpact();

                                scrollToSelectedCard(index);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Expanded Scrollable List with NotificationListener
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      double currentOffset = scrollNotification.metrics.pixels;

                      if (currentOffset >
                          _previousScrollOffset + _scrollThreshold) {
                        // Scrolling Down
                        if (_showAppHeader) {
                          setState(() {
                            _showAppHeader = false;
                            _showCategoryFilter = true;
                          });

                          // Perform scroll after the UI updates
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_showCategoryFilter && selectedIndex != -1) {
                              _scrollToCategory(selectedIndex);
                            }
                          });
                        }
                      } else if (currentOffset <
                          _previousScrollOffset - _scrollThreshold) {
                        // Scrolling Up
                        if (!_showAppHeader || !_showCategoryFilter) {
                          setState(() {
                            _showAppHeader = true;
                            _showCategoryFilter = true;
                          });

                          // Optionally, perform scroll when scrolling up
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_showCategoryFilter && selectedIndex != -1) {
                              _scrollToCategory(selectedIndex);
                            }
                          });
                        }
                      }

                      // At the top of the list
                      if (scrollNotification.metrics.pixels <= 0) {
                        setState(() {
                          _showAppHeader = true;
                          _showCategoryFilter = false;
                        });
                      }

                      _previousScrollOffset = currentOffset;
                    }
                    return false;
                  },
                  child: Consumer<ServiceTypeProvider>(
                    builder: (context, serviceTypeProvider, child) {
                      final groups = serviceTypeProvider.groups;
                      final isLoading = serviceTypeProvider.isLoading;
                      final errorMessage = serviceTypeProvider.errorMessage;
                      final localizations = AppLocalizations.of(context);

                      // Determine if there are groups to display
                      bool hasGroups = groups != null && groups.isNotEmpty;

                      // Define the total item count based on the state
                      int itemCount;
                      if (isLoading) {
                        // Search bar + 3 shimmer cards
                        itemCount = 1 + 3;
                      } else if (errorMessage != null) {
                        itemCount = 2; // Search bar + error message
                      } else if (!hasGroups) {
                        itemCount = 2; // Search bar + empty state
                      } else {
                        itemCount = groups.length + 1; // Search bar + groups
                      }

                      return ScrollablePositionedList.builder(
                        itemCount: itemCount,
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _itemPositionsListener,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Search Bar as the first item
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 16.h),
                              child: CustomSearchBar(
                                fem: fem,
                                serviceTypeId: widget.serviceTypeId,
                                onSearchStatusChanged:
                                    _handleSearchStatusChanged,
                              ),
                            );
                          } else {
                            if (isLoading) {
                              // Shimmer cards during loading
                              return buildShimmerCard(fem);
                            } else if (errorMessage != null) {
                              // Error Message as the second item
                              return Padding(
                                padding: EdgeInsets.all(24.w),
                                child: SystemEmptyPage(
                                  fem: fem,
                                  iconUrl: 'assets/Icons/errorPageIcon.svg',
                                  title: localizations.translate('error_title'),
                                  subtitle: errorMessage,
                                  showButton: true,
                                  enableRefresh: true,
                                  backgroundColor: AppColors.gray10,
                                  buttonAction: () async {
                                    await serviceTypeProvider.fetchServiceTypes(
                                        widget.serviceTypeId);
                                  },
                                  buttonText:
                                      localizations.translate('retry_button'),
                                  useScaffold: false,
                                  isInside: true,
                                ),
                              );
                            } else if (!hasGroups) {
                              // Empty State as the second item
                              return Padding(
                                padding: EdgeInsets.all(24.w),
                                child: _isSearch
                                    ? NoResultsComponent()
                                    : SystemEmptyPage(
                                        fem: fem,
                                        iconUrl:
                                            'assets/Icons/EmptyBasketIcon.svg',
                                        title: localizations
                                            .translate('no_services_title'),
                                        subtitle: localizations
                                            .translate('no_services_subtitle'),
                                        showButton: true,
                                        enableRefresh: true,
                                        backgroundColor: AppColors.gray10,
                                        buttonAction: () async {
                                          await serviceTypeProvider
                                              .fetchServiceTypes(
                                                  widget.serviceTypeId,
                                                  forceRefresh: true);
                                        },
                                        buttonText: localizations.translate(
                                            'check_again_button_text'),
                                        useScaffold: false,
                                        isInside: true,
                                      ),
                              );
                            } else {
                              // Display Group Items
                              final group = groups[index - 1];
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: 16 * fem, right: 25.w, left: 24.w),
                                child: MainCard(
                                  title: group.groupName,
                                  pricePerUnit: group.pricePer ?? '',
                                  items: group.products
                                      .map((product) => {
                                            'productId': product.productId,
                                            'imagePathThum':
                                                Config.resolveImageUrl(
                                                    product.thumbnailPath),
                                            'imagePath': Config.resolveImageUrl(
                                                product.imagePath),
                                            'label': product.productName,
                                            'area': (product.area),
                                          })
                                      .toList(),
                                  fem: fem,
                                  fetchProductServices:
                                      serviceTypeProvider.getProductServices,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
