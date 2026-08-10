// lib/pages/onboarding_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Indicator/GradientCustomIndicator.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Navigator/startup_router.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/utils/OnboardingProvider.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

// ─────────────────────────────────────────────────────────────────────────
// ملاحظات على هاي النسخة (تعديل بعد الملاحظات):
//
// 1) شلنا البانل الزجاجي الكبير يلي كان خلف النص بالكامل - كان عم يغطي
//    جزء كبير من الصورة. هلأ النص (dots/عنوان/وصف) عايش مباشرة فوق
//    الصورة، معتمد على التدرج المدموج بالصورة نفسها للوضوح (بدون أي
//    عنصر إضافي وراه).
//
// 2) زر تجاهل/Skip صار بالزاوية العلوية مقابل زر اللغة تماماً - كبسولة
//    زجاجية صغيرة فيها بس النص (بنفس خط التطبيق)، بتختفي بآخر صفحة.
//
// 3) زر "التالي" صار دائري زجاجي ضبابي (زي زر اللغة بالضبط بالستايل)
//    فيه سهم بيتجه يمين أو شمال حسب اللغة المختارة، بدل الزر المستطيل
//    الكبير. بآخر صفحة بيتحول لزر "Start" بعرض كامل (نفس منطق الترتيب
//    السابق: AnimatedSwitcher بين الحالتين).
//
// 4) نزّلنا كتلة (العنوان + الوصف + النقاط) لتحت أكتر، وقرّبناها من الزر:
//    قللنا المسافتين قبل النقاط وبعدها (كانوا 18.h و20.h، صاروا 8.h و6.h).
//    الزر نفسه ما انلمس ولا سطر - وضل بمكانه القديم بالضبط، لأنه آخر
//    عنصر بالعمود وموضعه أصلاً ثابت بالنسبة لأسفل الشاشة بغض النظر عن
//    قد ايش فوقه من مسافات. لو لسا بدك تنزلهن أكتر: قلل هالرقمين
//    (8.h / 6.h) أكتر، بس خلي شوي مسافة تنفس ولا توصلهن لصفر عشان ما
//    تلزق النقاط بالزر.
// ─────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasNavigated = false;
  String? _preloadedLocationLanguage;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // الصور الثابتة المحلية - بدل صور لوحة التحكم (imageUrlEn/imageUrlAr).
  static const List<String> _staticOnboardingImages = [
    'assets/images/dry_clean_onboarding_1.png',
    'assets/images/dry_clean_onboarding_2.png',
    'assets/images/dry_clean_onboarding_3.png',
  ];

  // لون تعبئة الزر الدائري (Next) وزر Start - تركوازي بهوية Saleem.
  // ⚠️ لو عندك لون رسمي بـ AppColors بنفس درجة زر Start الأصلي، بدّل
  // القيمتين هون فيه مباشرة عشان يطابق باقي التطبيق تماماً.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.12),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = context.read<LanguageProvider>().locale.languageCode;
    if (_preloadedLocationLanguage == languageCode) return;
    _preloadedLocationLanguage = languageCode;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final location = context.read<LocationScopeProvider>();
      await location.restore();
      if (!mounted || location.isChosen) return;
      if (location.governatesLanguage != languageCode) {
        await location.loadGovernates(lang: languageCode);
      }
    });
  }

  Widget _buildDots(int count, int activeIndex) {
    return GradientCustomIndicator(
      activeIndex: activeIndex,
      fem: 1,
      count: count,
    );
  }

  Future<void> _navigateToMain(OnboardingProvider onboardingProvider) async {
    if (!_hasNavigated) {
      _hasNavigated = true;
      try {
        await onboardingProvider.completeOnboarding();
        if (!mounted) return;
        final destination = await StartupRouter.resolve(context);
        if (!mounted) return;
        NavigatorService.navigateToAndRemoveUntil(destination);
      } catch (e) {
        print('Error during navigation: $e');
        NavigatorService.navigateTo(RouteNames.error);
      }
    }
  }

  void _goToNextPage(OnboardingProvider onboardingProvider) {
    if (_currentPage < onboardingProvider.steps.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _navigateToMain(onboardingProvider);
    }
  }

  void _replayEntranceAnimation() {
    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    bool isEnglish = languageProvider.locale.languageCode == 'en';
    bool isLastPage = _currentPage == onboardingProvider.steps.length - 1;
    // السهم بيتجه بنفس اتجاه القراءة الحالي: يمين بالإنجليزي، شمال بالعربي.
    final IconData nextArrowIcon =
        Directionality.of(context) == TextDirection.rtl
            ? Icons.arrow_forward_rounded
            : Icons.arrow_forward_rounded;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!onboardingProvider.isActive || onboardingProvider.hasCompleted) {
        _navigateToMain(onboardingProvider);
      }
    });

    if (onboardingProvider.isLoading) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Image.asset(
            _staticOnboardingImages.first,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // أيقونات شريط الحالة (الوقت/البطارية) بيضاء عشان تبين فوق الصورة.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: onboardingProvider.isActive && !onboardingProvider.hasCompleted
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // **1. الصورة تغطي الشاشة بالكامل - بدون أي منازع**
                  PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingProvider.steps.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _replayEntranceAnimation();
                    },
                    itemBuilder: (context, index) {
                      final imagePath = _staticOnboardingImages[
                          index % _staticOnboardingImages.length];

                      return Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_rounded,
                                color: Colors.white54, size: 48),
                          ),
                        ),
                      );
                    },
                  ),

                  // **2. الزاوية العلوية: زر Skip مقابل زر اللغة**
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isLastPage
                                ? SizedBox(width: 44.w)
                                : _GlassPillButton(
                                    text: localizations.translate('skip'),
                                    filled: false,
                                    compact: true,
                                    onTap: () =>
                                        _navigateToMain(onboardingProvider),
                                  ),
                            _GlassIconButton(
                              icon: Icons.language_rounded,
                              onTap: () => languageProvider.toggleLanguage(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // **3. النص + الأزرار مباشرة فوق الصورة - بدون أي بانل**
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            // قللنا الفراغ السفلي عشان الكتلة تنزل لتحت أكتر
                            // (جوا الجزء الغامق من تدرج الصورة). عدّل الرقم
                            // 6.h لو بدك تتحكم أكتر بمقدار النزول.
                            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 6.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isEnglish
                                      ? onboardingProvider
                                          .steps[_currentPage].titleEn
                                      : onboardingProvider
                                          .steps[_currentPage].titleAr,
                                  style: AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray80(context)
                                        .copyWith(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                      color: Colors.white,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  isEnglish
                                      ? onboardingProvider
                                          .steps[_currentPage].messageEn
                                      : onboardingProvider
                                          .steps[_currentPage].messageAr,
                                  style: AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray80(context)
                                        .copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      color:
                                          Colors.white.withValues(alpha: 0.88),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (onboardingProvider
                                            .steps[_currentPage].subMessageEn !=
                                        null &&
                                    onboardingProvider
                                            .steps[_currentPage].subMessageAr !=
                                        null) ...[
                                  SizedBox(height: 6.h),
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
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                SizedBox(height: 8.h),
                                _buildDots(onboardingProvider.steps.length,
                                    _currentPage),
                                SizedBox(height: 6.h),

                                // زر Start (آخر صفحة) أو الزر الدائري Next
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                  child: isLastPage
                                      ? _GlassPillButton(
                                          key: ValueKey('StartButton'),
                                          text:
                                              localizations.translate('Start'),
                                          filled: true,
                                          fullWidth: true,
                                          onTap: () => _navigateToMain(
                                              onboardingProvider),
                                        )
                                      : Align(
                                          key: ValueKey('NextButton'),
                                          alignment:
                                              AlignmentDirectional.bottomEnd,
                                          child: _GlassIconButton(
                                            icon: nextArrowIcon,
                                            filled: true,
                                            size: 45,
                                            onTap: () => _goToNextPage(
                                                onboardingProvider),
                                          ),
                                        ),
                                ),
                                SizedBox(height: 15.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox.shrink(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// أزرار وأيقونات زجاجية (glassmorphism) مخصّصة لشاشة الأونبوردنج
// ─────────────────────────────────────────────────────────────────────────

/// زر أيقونة دائري زجاجي شفاف. `filled: true` بيدي تلوين تركوازي خفيف
/// (للفعل الأساسي متل Next)، بينما `filled: false` بيضل شفاف محايد
/// (للأفعال الثانوية متل اللغة/الرجوع).
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final double size;

  const _GlassIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.size = 44,
  }) : super(key: key);

  static const Color _tealStart = Color(0xFF12B3A0);
  static const Color _tealEnd = Color(0xFF0B7A6E);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size.w,
              height: size.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: filled
                    ? LinearGradient(
                        colors: [
                          _tealStart.withValues(alpha: 0.9),
                          _tealEnd.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: filled ? null : Colors.white.withValues(alpha: 0.16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: filled ? 0.45 : 0.35),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: size.w * 0.42),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر كبسولة (pill) زجاجي - `compact: true` بياخد حجم النص بالضبط
/// (لزر Skip بالزاوية)، وإلا بياخد المساحة المتاحة (لزر Start).
class _GlassPillButton extends StatelessWidget {
  final String text;
  final bool filled;
  final bool fullWidth;
  final bool compact;
  final VoidCallback onTap;

  const _GlassPillButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.filled = false,
    this.fullWidth = false,
    this.compact = false,
  }) : super(key: key);

  static const Color _tealStart = Color(0xFF12B3A0);
  static const Color _tealEnd = Color(0xFF0B7A6E);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 22.w : 16.w),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: fullWidth ? double.infinity : null,
              height: compact ? 44.w : 52.h,
              padding: compact
                  ? EdgeInsets.symmetric(horizontal: 18.w)
                  : EdgeInsets.zero,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(compact ? 22.w : 16.w),
                gradient: filled
                    ? LinearGradient(
                        colors: [
                          _tealStart.withValues(alpha: 0.85),
                          _tealEnd.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: filled ? null : Colors.white.withValues(alpha: 0.14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: filled ? 0.4 : 0.32),
                  width: 1,
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.getFontFamily(
                  context,
                  TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
