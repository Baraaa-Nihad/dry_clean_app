import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Ensure this import is correct

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final dynamic prefixIcon; // Accept either Widget or String
  final dynamic suffixIcon; // Accept either Widget or String
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final bool quantityNumber;

  final double fem;
  final Color? backgroundColor;
  // Static method to get the height based on fem
  static double getHeight(double fem) => 116.0 * fem;

  const AppHeader({
    Key? key,
    required this.quantityNumber,
    required this.title,
    this.prefixIcon,
    this.suffixIcon,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    this.backgroundColor: AppColors.white,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);

    return PreferredSize(
      preferredSize: Size.fromHeight(getHeight(fem)),
      child: Container(
        height: getHeight(fem),
        color: backgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * fem)
              .copyWith(top: 40 * fem),
          child: Row(
            children: [
              if (prefixIcon != null)
                GestureDetector(
                  onTap: onPrefixIconTap,
                  child: prefixIcon is String
                      ? SizedBox(
                          width: 85 * fem,
                          height: 95 * fem,
                          child: SvgPicture.asset(prefixIcon),
                        )
                      : prefixIcon as Widget,
                ),
              if (prefixIcon == null) SizedBox(width: 0 * fem),
              Expanded(
                child: Align(
                  alignment: prefixIcon != null
                      ? Alignment.center
                      : isRtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (prefixIcon != null ? 24 : 24) * fem),
                    child: Text(
                      localizations?.translate(title) ?? title,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.bold16Gray80(context).copyWith(
                            fontSize: 18.0 * fem, fontWeight: FontWeight.w600),
                      ),
                      textAlign: prefixIcon != null
                          ? TextAlign.center
                          : isRtl
                              ? TextAlign.right
                              : TextAlign.left,
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null)
                GestureDetector(
                  onTap: onSuffixIconTap,
                  child: suffixIcon is String
                      ? SizedBox(
                          width: 85 * fem,
                          height: 95 * fem,
                          child: SvgPicture.asset(suffixIcon),
                        )
                      : suffixIcon as Widget,
                ),
              if (suffixIcon == null) SizedBox(width: 60 * fem),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(getHeight(fem));
}
