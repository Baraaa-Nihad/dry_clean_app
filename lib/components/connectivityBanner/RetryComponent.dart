// lib/components/retry_component.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class RetryComponent extends StatelessWidget {
  final String svgAssetPath;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final double fem;

  const RetryComponent({
    Key? key,
    required this.svgAssetPath,
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.fem = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0 * fem),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG Image
            SvgPicture.asset(
              svgAssetPath,
              width: 182 * fem,
              height: 182 * fem,
            ),
            SizedBox(height: 24 * fem),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 18.0 * fem,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray70),
              ),
            ),
            SizedBox(height: 8 * fem),
            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 14.0 * fem,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray50),
              ),
            ),
            SizedBox(height: 30 * fem),
            // LoadingButton
            LoadingButton(
              fem: fem,
              buttonText: '${localizations?.translate('Retry') ?? 'Retry'}',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
