// lib/screens/empty_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/CustomRefreshIndicator/CustomRefreshIndicator.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class EmptyPage extends StatelessWidget {
  final double fem;
  final String title;
  final String subtitle;
  final bool showButton;
  final String buttonText;
  final String iconUrl;
  final VoidCallback? buttonAction;
  final Future<void> Function()?
      onRefresh; // Function to handle refresh (optional)
  final bool enableRefresh; // Optional flag for enabling refresh
  final Color backgroundColor; // New optional backgroundColor parameter

  const EmptyPage({
    Key? key,
    required this.fem,
    required this.title,
    required this.iconUrl,
    required this.subtitle,
    this.showButton = false,
    this.buttonText = '',
    this.buttonAction,
    this.onRefresh, // Optional refresh callback
    this.enableRefresh = false, // Default no refresh
    this.backgroundColor = AppColors.gray10, // Default background color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    Widget pageContent = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * fem),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.2), // To center the content
            SvgPicture.asset(
              iconUrl, // Path to your SVG file
              width: 182 * fem,
              height: 182 * fem,
            ),
            SizedBox(height: 40 * fem),
            Text(
              title,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 18.0 * fem,
                    fontWeight: FontWeight.w600,
                    height: 0,
                    color: AppColors.gray70),
              ),
            ),
            SizedBox(height: 8 * fem),
            Text(
              subtitle,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray50),
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton) ...[
              SizedBox(height: 40 * fem),
              PrimaryButton(
                prefixIcon: 'assets/Icons/AddButtonIcon.svg',
                buttonWidth: "full",
                fem: fem,
                text: buttonText,
                onPressed: buttonAction,
                isDisabled: false,
              ),
            ],
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.2), // Space for pull-to-refresh gesture
          ],
        ),
      ),
    );

    if (enableRefresh && onRefresh != null) {
      return Scaffold(
        backgroundColor: backgroundColor, // Use the provided backgroundColor
        body: CustomRefreshIndicator(
          onRefresh: onRefresh!,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: pageContent,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: backgroundColor, // Use the provided backgroundColor
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: pageContent,
        ),
      );
    }
  }
}
