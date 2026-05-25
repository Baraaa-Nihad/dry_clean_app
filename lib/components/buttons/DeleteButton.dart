import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/style/AppDeleteButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppPrimaryButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class DeleteButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final double fem;
  final String buttonWidth; // Changed isFullWidth to buttonWidth

  const DeleteButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    required this.fem,
    this.buttonWidth = 'full', // Default to 'full'
  }) : super(key: key);

  double _getWidth() {
    switch (buttonWidth) {
      case 'small':
        return 146 * fem;

      case 'medium':
        return 182 * fem; // Adjust this if you need a different medium width
      case 'large':
        return 272 * fem; // Adjust this if you need a different medium width
      case 'full':
      default:
        return 360 * fem;
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
              height: 56 * fem, // Fixed height for
              decoration: AppDeleteButtonStyles.getDecoration(isDisabled),
              child: ElevatedButton(
                onPressed: isDisabled ? null : onPressed,
                style:
                    AppDeleteButtonStyles.getButtonStyle(context, isDisabled),
                child: isLoading
                    ? LoadingDots(fem: fem)
                    : Text(
                        text,
                        style: AppTextStyles.bold16White(context).copyWith(
                          fontSize: 16 * fem,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
