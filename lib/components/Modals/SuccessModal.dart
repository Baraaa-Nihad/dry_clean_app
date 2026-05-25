import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class SuccessModal extends StatefulWidget {
  final String message;
  final String title;
  final Widget mainButton;
  final Widget? secondaryButton;
  final Widget? customComponent;
  final bool isDismissible;
  final bool isCloseable; // New flag for close icon visibility

  const SuccessModal({
    required this.message,
    required this.title,
    required this.mainButton,
    this.secondaryButton,
    this.customComponent,
    this.isDismissible = true,
    this.isCloseable = true, // Default value is true
    Key? key,
  }) : super(key: key);

  @override
  _SuccessModalState createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56,
        minHeight: MediaQuery.of(context).size.height - 56,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.isCloseable) // Show close icon based on the flag
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/vectors/close_icon.svg',
                  width: 48.0,
                  height: 48.0,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/vectors/success_icon.svg', // Replace with your success icon asset
                    width: 165.0,
                    height: 160.0,
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    localizations?.translate(widget.title) ?? widget.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.bold16Gray80(context).copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    localizations?.translate(widget.message) ?? widget.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray50(context).copyWith(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  if (widget.customComponent != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: widget.customComponent,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: widget.mainButton,
                ),
                if (widget.secondaryButton != null) ...[
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    child: widget.secondaryButton!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
