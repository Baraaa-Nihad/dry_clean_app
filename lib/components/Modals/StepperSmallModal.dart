// lib/components/modals/SmallModal.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class StepperSmallModal extends StatefulWidget {
  final String? prefixIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onPressed;
  final VoidCallback? onCancel;
  final String primaryButtonLable;

  final double fem;
  final String title;
  final String message;
  final Widget? child; // Optional widget parameter

  // New parameters for stepper dots
  final int currentStep;
  final int totalSteps;

  const StepperSmallModal({
    Key? key,
    required this.primaryButtonLable,
    this.prefixIconPath,
    this.onPrefixIconTap,
    this.onPressed,
    this.onCancel,
    required this.fem,
    required this.title,
    required this.message,
    this.child, // Initialize the child
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    String? prefixIconPath,
    required String primaryButtonLable,
    VoidCallback? onPrefixIconTap,
    VoidCallback? onPressed,
    VoidCallback? onCancel,
    required double fem,
    required String title,
    required String message,
    Widget? child, // Optional child widget
    required int currentStep, // Required for dots
    required int totalSteps, // Required for dots
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => StepperSmallModal(
        primaryButtonLable: primaryButtonLable,
        prefixIconPath: prefixIconPath,
        onPrefixIconTap: onPrefixIconTap,
        onPressed: onPressed,
        onCancel: onCancel,
        fem: fem,
        title: title,
        message: message,
        child: child, // Pass child to the modal
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  _SmallModalState createState() => _SmallModalState();
}

class _SmallModalState extends State<StepperSmallModal> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Detect keyboard height
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
          bottom: keyboardHeight), // Adjust padding when keyboard is open
      child: Container(
        // Adjust height based on content and steps
        // For example, base height plus additional height per step
        height:
            322 * widget.fem + (widget.totalSteps > 0 ? 20 * widget.fem : 0),
        padding: EdgeInsets.symmetric(horizontal: 24 * widget.fem),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.green, width: 2),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stepper Dots
              if (widget.totalSteps > 0)
                _buildDots(widget.currentStep, widget.totalSteps),
              SizedBox(height: 16 * widget.fem),
              Align(
                alignment: Alignment.topLeft,
                child: widget.prefixIconPath != null
                    ? IconButton(
                        icon: SvgPicture.asset(widget.prefixIconPath!),
                        onPressed: widget.onPrefixIconTap,
                      )
                    : SizedBox.shrink(),
              ),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 20.0 * widget.fem,
                    fontWeight: FontWeight.w700,
                    height: 0,
                    color: AppColors.gray80,
                  ),
                ),
              ),
              SizedBox(height: 8 * widget.fem),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray50,
                  ),
                ),
              ),
              if (widget.child != null) ...[
                SizedBox(height: 16 * widget.fem),
                widget.child!,
              ],
              SizedBox(height: 24 * widget.fem),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      fem: widget.fem,
                      buttonWidth: "medium",
                      isDisabled: false,
                      text: localizations.translate(widget.primaryButtonLable),
                      onPressed: widget.onPressed,
                    ),
                  ),
                  SizedBox(width: 16 * widget.fem),
                  Expanded(
                    child: SecondaryButton(
                      fem: widget.fem,
                      buttonWidth: "medium",
                      isDisabled: false,
                      text: localizations.translate('Cancel'),
                      onPressed: widget.onCancel,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * widget.fem),
            ],
          ),
        ),
      ),
    );
  }

  // New method to build stepper dots
  Widget _buildDots(int currentStep, int totalSteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: currentStep == index + 1 ? 12.w : 8.w,
          height: currentStep == index + 1 ? 12.w : 8.w,
          decoration: BoxDecoration(
            color: currentStep == index + 1
                ? Theme.of(context).primaryColor
                : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
