// lib/components/BottomNav/BottomNavItem.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saleem_dry_clean/theme/app_theme.dart';

class BottomNavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final String filledIconPath;

  final VoidCallback onTap;
  final int notificationCount;

  const BottomNavItem({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.filledIconPath,
    required this.onTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // تم تعديل الـ Padding السفلي من 32.h إلى 8.h ليتزن عمودياً داخل الـ Bar
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: SvgPicture.asset(
                      isActive ? filledIconPath : iconPath,
                      key: ValueKey<bool>(isActive),
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Center(
                          child: Text(
                            '$notificationCount',
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.regular14RedW500(context).copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 4.h), // مساحة بينية صغيرة ومناسبة
            isActive
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.getHorizontalPrimaryGradient(context)
                            .createShader(bounds),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: AppColors.gray40,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
