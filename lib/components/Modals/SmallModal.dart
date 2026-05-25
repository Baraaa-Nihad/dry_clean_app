import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class SmallModal extends StatefulWidget {
  final String? prefixIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onPressed;
  final VoidCallback? onCancel;
  final bool isLoading; // Changed to non-nullable bool

  final String primaryButtonLable;
  final double fem;
  final String title;
  final String message;
  final Widget? child; // Optional widget parameter

  const SmallModal({
    Key? key,
    required this.primaryButtonLable,
    this.prefixIconPath,
    this.onPrefixIconTap,
    this.onPressed,
    required this.isLoading, // Required isLoading
    this.onCancel,
    required this.fem,
    required this.title,
    required this.message,
    this.child, // Initialize the child
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
    required bool isLoading, // Pass the isLoading parameter here
    Widget? child, // Optional child widget
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => SmallModal(
        primaryButtonLable: primaryButtonLable,
        prefixIconPath: prefixIconPath,
        onPrefixIconTap: onPrefixIconTap,
        onPressed: onPressed,
        onCancel: onCancel,
        fem: fem,
        title: title,
        message: message,
        isLoading: isLoading, // Pass isLoading to SmallModal constructor
        child: child, // Pass child to the modal
      ),
    );
  }

  @override
  _SmallModalState createState() => _SmallModalState();
}

class _SmallModalState extends State<SmallModal> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Detect keyboard height
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
          bottom: keyboardHeight), // Adjust padding when keyboard is open
      child: Container(
        height: 322 * widget.fem,
        padding: EdgeInsets.symmetric(horizontal: 24 * widget.fem),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.green, width: 2),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: widget.prefixIconPath != null
                  ? IconButton(
                      icon: SvgPicture.asset(widget.prefixIconPath!),
                      onPressed: widget.onPrefixIconTap,
                    )
                  : const SizedBox.shrink(),
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
            const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              widget.child!,
            ],
            SizedBox(height: 40 * widget.fem),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: LoadingButton(
                    fem: widget.fem,
                    buttonWidth: "medium",
                    isDisabled: false,
                    isLoading: widget.isLoading, // Handle isLoading state
                    buttonText:
                        localizations.translate(widget.primaryButtonLable),
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
            SizedBox(height: 60 * widget.fem),
          ],
        ),
      ),
    );
  }
}
