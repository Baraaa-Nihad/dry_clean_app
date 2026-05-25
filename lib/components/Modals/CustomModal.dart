import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CustomModal extends StatelessWidget {
  final String mainTitle;
  final String? prefixIconPath;
  final String? suffixIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final double fem;
  final bool isDisabledButton;
  final Widget content; // Dynamic content widget

  const CustomModal({
    Key? key,
    required this.mainTitle,
    this.prefixIconPath,
    this.suffixIconPath,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    required this.fem,
    required this.isDisabledButton,
    required this.content, // Initialize content widget
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String mainTitle,
    String? subTitle,
    String? prefixIconPath,
    String? suffixIconPath,
    VoidCallback? onPrefixIconTap,
    VoidCallback? onSuffixIconTap,
    required double fem,
    required bool isDisabledButton,
    required Widget content, // Pass content widget
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => CustomModal(
        mainTitle: mainTitle,
        prefixIconPath: prefixIconPath,
        suffixIconPath: suffixIconPath,
        onPrefixIconTap: onPrefixIconTap,
        onSuffixIconTap: onSuffixIconTap,
        fem: fem,
        isDisabledButton: isDisabledButton,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double modalHeight = MediaQuery.of(context).size.height - 56;
    final localizations = AppLocalizations.of(context);

    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: modalHeight,
                maxHeight: modalHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 88 * fem, // Fixed height for the stack
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: 16,
                    ),
                    child: Stack(
                      children: [
                        if (prefixIconPath != null)
                          Positioned(
                            left: 0,
                            child: GestureDetector(
                              onTap: onPrefixIconTap,
                              child: SvgPicture.asset(
                                prefixIconPath!,
                                width: 48 * fem,
                                height: 48 * fem,
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localizations.translate(mainTitle),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.bold16Gray80(context).copyWith(
                                      fontSize: 18.0 * fem,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (suffixIconPath != null)
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: onSuffixIconTap,
                              child: SvgPicture.asset(
                                suffixIconPath!,
                                width: 24 * fem,
                                height: 24 * fem,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12 * fem),
                      child: content,
                    ), // Display the dynamic content
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
