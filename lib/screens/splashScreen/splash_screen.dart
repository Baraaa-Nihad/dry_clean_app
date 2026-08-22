import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Navigator/startup_router.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _animationFinished = false;
  bool _startupFinished = false;
  bool _animationStarted = false;
  bool _hasNavigated = false;
  String? _destination;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _prepareDestination(),
    );
  }

  Future<void> _prepareDestination() async {
    try {
      final destination = await StartupRouter.resolve(context);

      if (!mounted) return;

      _destination = destination;
    } catch (error) {
      debugPrint('SplashScreen: startup failed: $error');

      if (!mounted) return;

      _destination = RouteNames.error;
    } finally {
      if (mounted) {
        _startupFinished = true;
        _navigateWhenReady();
      }
    }
  }

  void _navigateWhenReady() {
    if (_hasNavigated ||
        !_animationFinished ||
        !_startupFinished) {
      return;
    }

    final destination = _destination;

    if (destination == null) return;

    _hasNavigated = true;

    NavigatorService.navigateToAndRemoveUntil(destination);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Top: soft mint / greenish aqua
              Color(0xFF8FD8C9),

              // Upper-middle: aqua
              Color(0xFF56CFCB),

              // Center: stronger turquoise
              Color(0xFF25B8C2),

              // Bottom: deep Saleem teal
              Color(0xFF087F9E),
            ],
            stops: [
              0.0,
              0.27,
              0.58,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [

            // ============================================================
            // TOP-RIGHT MINT/GREEN GLOW
            // Keeps the green concentrated in the corner.
            // ============================================================
            Positioned(
              top: -170.h,
              right: -150.w,
              child: Container(
                width: 430.w,
                height: 430.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.75,
                    colors: [
                      Color(0xFFB9F2C3),
                      Color(0xFF9DE7C4),
                      Color(0x0056CFCB),
                    ],
                    stops: [
                      0.0,
                      0.45,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // TOP-LEFT SOFT MINT GLOW
            // Gives the same airy feeling as the onboarding screens.
            // ============================================================
            Positioned(
              top: -120.h,
              left: -150.w,
              child: Container(
                width: 360.w,
                height: 360.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Color(0xFFB5EAC8),
                      Color(0x006ED7CA),
                    ],
                    stops: [
                      0.0,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // VERY SUBTLE WHITE LIGHT
            // Not behind the logo, just a soft atmospheric highlight.
            // ============================================================
            Positioned(
              top: -100.h,
              left: 80.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.035),
                ),
              ),
            ),

            // ============================================================
            // BOTTOM DEPTH
            // Adds the same curved / layered feeling from onboarding.
            // ============================================================
            Positioned(
              bottom: -190.h,
              left: -100.w,
              child: Container(
                width: 520.w,
                height: 360.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.045),
                ),
              ),
            ),

            Positioned(
              bottom: -240.h,
              right: -150.w,
              child: Container(
                width: 500.w,
                height: 380.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.035),
                ),
              ),
            ),

            // ============================================================
            // LOGO / LOTTIE
            // ============================================================
            Align(
              alignment: const Alignment(0, -0.50),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Lottie.asset(
                  'assets/animations/S - White.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    if (_animationStarted) return;

                    _animationStarted = true;

                    _controller.duration = composition.duration;

                    _controller.forward().whenComplete(() {
                      if (!mounted) return;

                      _animationFinished = true;

                      _navigateWhenReady();
                    });
                  },
                  width: 300.w,
                  height: 300.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}