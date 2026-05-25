// lib/components/EmptyPage/SystemEmptyPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/CustomRefreshIndicator/CustomRefreshIndicator.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SystemEmptyPage extends StatelessWidget {
  final double fem;
  final String title;
  final String subtitle;
  final bool showButton;
  final String buttonText;
  final String iconUrl;
  final VoidCallback? buttonAction;
  final Future<void> Function()? onRefresh;
  final bool enableRefresh;
  final Color backgroundColor;
  final bool useScaffold;
  final bool isInside;

  const SystemEmptyPage({
    Key? key,
    required this.fem,
    required this.title,
    required this.iconUrl,
    required this.subtitle,
    this.showButton = false,
    this.buttonText = '',
    this.buttonAction,
    this.onRefresh,
    this.enableRefresh = false,
    this.backgroundColor = AppColors.gray10,
    this.useScaffold = false,
    this.isInside = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Conditionally set horizontal padding based on isInside flag
    double horizontalPadding = isInside ? 0.w : 24.w;

    Widget pageContent = Column(
      mainAxisSize: MainAxisSize.min, // Minimize vertical space usage
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
      children: [
        Center(
          // Ensure the SVG is centered
          child: SvgPicture.asset(
            iconUrl, // Path to your SVG file
            width: 182.w,
            height: 182.h,
            fit: BoxFit.contain,
            placeholderBuilder: (BuildContext context) => Icon(
              Icons.error,
              size: 182.w,
              color: AppColors.gray50,
            ),
          ),
        ),
        SizedBox(height: 40.h),
        Text(
          title,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 18.0.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.gray70,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.gray50,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        if (showButton) ...[
          SizedBox(height: 40.h),
          PrimaryButton(
            buttonWidth: "full",
            fem: fem,
            text: buttonText,
            onPressed: buttonAction,
            isDisabled: false,
          ),
        ],
      ],
    );

    Widget content = Center(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 150),
        child: pageContent,
      ),
    );

    if (enableRefresh && onRefresh != null) {
      content = CustomRefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: pageContent,
          ),
        ),
      );
    }

    if (useScaffold) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: content, // Use centered content
      );
    } else {
      return Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: content,
      );
    }
  }
}
