// lib/pages/onboarding_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Indicator/GradientCustomIndicator.dart';
import 'package:saleem_dry_clean/components/buttons/LanguageButton.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/OnboardingProvider.dart';
import 'package:saleem_dry_clean/utils/connectivity_service.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasNavigated = false; // Flag to prevent multiple navigations

  // Animation Controller for Modal Slide-Up
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: 600), // Increased duration for smoothness
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Starts below the screen
      end: Offset(0, 0), // Ends at its natural position
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Smoother curve
      ),
    );

    // Start the slide-up animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  // Method to build stepper dots
  Widget _buildDots(int count, int activeIndex) {
    return GradientCustomIndicator(
      activeIndex: activeIndex,
      fem: 1,
      count: count,
    );
  }

  // Method to handle navigation after completing onboarding
  Future<void> _navigateToMain(OnboardingProvider onboardingProvider) async {
    if (!_hasNavigated) {
      _hasNavigated = true; // Prevent re-navigation
      try {
        print('Completing onboarding...');
        await onboardingProvider
            .completeOnboarding(context); // Await completion
        print('Navigating to main screen...');
        // Replace the current route with the main screen
        NavigatorService.navigateTo(RouteNames.main);
        // Alternatively, use Navigator.of(context).pushReplacementNamed(RouteNames.main);
      } catch (e) {
        print('Error during navigation: $e');
        // Optionally, navigate to ErrorPage or show a dialog
        NavigatorService.navigateTo(RouteNames.error);
      }
    }
  }

  // Method to navigate to the previous page
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    // Define fem for scaling
    double fem = 1.0; // Adjust this based on your design requirements
    // If using ScreenUtil, you might set it like:
    // double fem = ScreenUtil().scaleWidth;

    // Determine current language
    bool isEnglish = languageProvider.locale.languageCode == 'en';

    // Check onboarding status and navigate if necessary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!onboardingProvider.isActive || onboardingProvider.hasCompleted) {
        _navigateToMain(onboardingProvider);
      }
    });

    // Determine if the current page is the last page
    bool isLastPage = _currentPage == onboardingProvider.steps.length - 1;

    if (onboardingProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to extend behind system UI
      body: onboardingProvider.isActive && !onboardingProvider.hasCompleted
          ? Stack(
              children: [
                // **1. Gray Background Container**
                Positioned.fill(
                  child: Container(
                    color: AppColors.gray10, // Set the gray10 background
                  ),
                ),
                // **2. Background Image with Error Handling**
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingProvider.steps.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final step = onboardingProvider.steps[index];
                      final rawUrl =
                          isEnglish ? step.imageUrlEn : step.imageUrlAr;
                      final resolvedUrl = Config.resolveImageUrl(rawUrl);

                      Widget fallback = Container(
                        color: AppColors.gray10,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/default_icon.svg',
                            width: 100.w,
                            height: 100.h,
                            color: AppColors.gray70,
                            semanticsLabel: 'Default Icon',
                          ),
                        ),
                      );

                      if (resolvedUrl.startsWith('http')) {
                        return CachedNetworkImage(
                          imageUrl: resolvedUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: AppColors.gray10,
                          ),
                          errorWidget: (context, url, error) => fallback,
                        );
                      }

                      return Image.asset(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => fallback,
                      );
                    },
                  ),
                ),
                // **3. AppHeader Positioned at the Top**
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppHeader(
                    quantityNumber: true,
                    title: '',
                    fem: fem,
                    prefixIcon: _currentPage > 0
                        ? BackButtonWidget(
                            onTap: () {
                              _goToPreviousPage();
                            },
                          )
                        : null,
                    suffixIcon: _currentPage == 0
                        ? const LanguageButton()
                        : null, // Use the new widget
                  ),
                ),
                // **4. Modal with stepper and texts using SlideTransition**
                SlideTransition(
                  position: _slideAnimation,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      bottom:
                          true, // تفعيل الـ SafeArea من الأسفل لحماية الأزرار من التداخل
                      child: Container(
                        width: double.infinity,
                        // تم التعديل لتكون المسافات الداخلية متوازنة واحترافية من جميع الجهات
                        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.w),
                            topRight: Radius.circular(24.w),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0C7485B6),
                              blurRadius: 4,
                              offset: Offset(0, -4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // ليأخذ الكونتينر حجمه الطبيعي المريح
                          children: [
                            // Stepper Dots
                            _buildDots(
                                onboardingProvider.steps.length, _currentPage),
                            SizedBox(height: 24.h),

                            // Title
                            Text(
                              isEnglish
                                  ? onboardingProvider
                                      .steps[_currentPage].titleEn
                                  : onboardingProvider
                                      .steps[_currentPage].titleAr,
                              style: AppTextStyles.getFontFamily(
                                context,
                                AppTextStyles.regular16Gray80(context).copyWith(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: AppColors.gray80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),

                            // Message
                            Text(
                              isEnglish
                                  ? onboardingProvider
                                      .steps[_currentPage].messageEn
                                  : onboardingProvider
                                      .steps[_currentPage].messageAr,
                              style: AppTextStyles.getFontFamily(
                                context,
                                AppTextStyles.regular16Gray80(context).copyWith(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    color: AppColors.gray50),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Sub Message (if exists)
                            if (onboardingProvider
                                        .steps[_currentPage].subMessageEn !=
                                    null &&
                                onboardingProvider
                                        .steps[_currentPage].subMessageAr !=
                                    null) ...[
                              SizedBox(height: 8.h),
                              Text(
                                isEnglish
                                    ? onboardingProvider
                                        .steps[_currentPage].subMessageEn!
                                    : onboardingProvider
                                        .steps[_currentPage].subMessageAr!,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                          color: AppColors.gray40),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            // فاصل احترافي مريح للعين بين النصوص والأزرار السفلية
                            SizedBox(height: 32.h),

                            // **B. Buttons Section with AnimatedSwitcher**
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: isLastPage
                                  ? PrimaryButton(
                                      key: ValueKey('StartButton'),
                                      fem: 1,
                                      buttonWidth: "full",
                                      isDisabled: false,
                                      text: localizations.translate('Start'),
                                      onPressed: () async {
                                        await _navigateToMain(
                                            onboardingProvider);
                                      },
                                    )
                                  : Row(
                                      key: ValueKey('SkipNextButtons'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: SecondaryButton(
                                              fem: 1,
                                              buttonWidth: "medium",
                                              isDisabled: false,
                                              text: localizations
                                                  .translate('skip'),
                                              onPressed: () async {
                                                await _navigateToMain(
                                                    onboardingProvider);
                                              }),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: PrimaryButton(
                                            fem: 1,
                                            buttonWidth: "medium",
                                            isDisabled: false,
                                            text:
                                                localizations.translate('next'),
                                            onPressed: () async {
                                              if (_currentPage <
                                                  onboardingProvider
                                                          .steps.length -
                                                      1) {
                                                _pageController.nextPage(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeIn,
                                                );
                                              } else {
                                                await _navigateToMain(
                                                    onboardingProvider);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox
              .shrink(), // Return an empty widget if not active or completed
    );
  }

  // Handle the Retry button press
  Future<void> _handleRetry() async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    // Check connectivity before attempting to retry
    if (!connectivityService.isConnected) {
      print('RetryHandler: No internet connection. Cannot retry.');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      print('RetryHandler: Attempting to refresh user data');
      await userProvider.refreshUserData(context);
      print('RetryHandler: User data refreshed');

      if (connectivityService.isConnected) {
        Navigator.of(context, rootNavigator: true).pop(); // Close the modal

        print('RetryHandler: Modal dismissed after successful retry');
      }
    } catch (e) {
      print('RetryHandler: Retry failed with error: $e');
    }
  }
}
