// lib/screens/splashScreen/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // تم إزالة Future.delayed من هنا لأننا سنربط الانتقال بانتهاء حركة الملف
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون الخلفية الداكن ليطابق تصميم فيجما
      backgroundColor: AppColors.background,
      body: Center(
        child: Lottie.asset(
          // استخدام ملف التدرج اللوني الذي أرسله العميل
          'assets/animations/S - White.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;

            // تشغيل الأنيميشن لمرة واحدة، وبمجرد انتهائه ننتقل للشاشة التالية بانسيايبة
            _controller.forward().whenComplete(() {
              NavigatorService.replaceWith(RouteNames.decision);
            });
          },
          // تم تصغير الحجم قليلاً ليكون أنيقاً ومتناسقاً مثل تصميم فيجما تماماً
          width: 250.w,
          height: 250.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
