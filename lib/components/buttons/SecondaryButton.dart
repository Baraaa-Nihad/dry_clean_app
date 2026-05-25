import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/style/AppPrimaryButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppSecondaryButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final double fem;
  final String buttonWidth; // Changed isFullWidth to buttonWidth
  final Widget? prefixIcon; // Added prefixIcon parameter

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    required this.fem,
    this.buttonWidth = 'full', // Default to 'full'
    this.prefixIcon, // Initialize prefixIcon
  }) : super(key: key);

  double _getWidth() {
    switch (buttonWidth) {
      case 'small':
        return 146;
      case 'petiteMedium':
        return 173;
      case 'medium':
        return 182; // Adjust this if you need a different medium width
      case 'large':
        return 272; // Adjust this if you need a different medium width
      case 'full':
      default:
        return 360;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 56 * fem, // Minimum height for the button
            maxHeight: 56 * fem, // Maximum height for the button
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: _getWidth(), // Adjust width based on buttonWidth
              height: 56 * fem, // Fixed height for the button
              decoration: AppSecondaryButtonStyles.getDecoration(isDisabled),
              child: ElevatedButton(
                onPressed: isDisabled ? null : onPressed,
                style: AppSecondaryButtonStyles.getButtonStyle(
                    context, isDisabled),
                child: isLoading
                    ? LoadingDots(fem: fem)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (prefixIcon != null) ...[
                            prefixIcon!,
                            SizedBox(width: 8 * fem),
                          ],
                          Text(
                            localizations.translate(text),
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.bold16Gradient(context).copyWith(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                height: 2.4,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
