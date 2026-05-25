import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/style/AppPrimaryButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final double fem;
  final String buttonWidth;
  final String? prefixIcon; // Add prefixIcon parameter

  const PrimaryButton({
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
        return 380;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: AppPrimaryButtonStyles.getDecoration(isDisabled),
              child: ElevatedButton(
                onPressed: isDisabled ? null : onPressed,
                style:
                    AppPrimaryButtonStyles.getButtonStyle(context, isDisabled),
                child: isLoading
                    ? LoadingDots(fem: fem)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (prefixIcon != null) ...[
                            SvgPicture.asset(prefixIcon!),
                            SizedBox(
                                width:
                                    8 * fem), // Spacing between icon and text
                          ],
                          Text(
                            text,
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.regular16Gray80(context).copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                  color: AppColors.white),
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
