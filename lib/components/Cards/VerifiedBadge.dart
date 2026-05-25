import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Ensure this path is correct
import 'package:saleem_dry_clean/theme/AppColors.dart'; // Ensure this path is correct
import 'package:saleem_dry_clean/style/AppTextStyles.dart'; // Ensure this path is correct

class VerifiedBadge extends StatelessWidget {
  final double paddingHorizontal;
  final double paddingVertical;
  final double borderRadius;
  final double iconSize;
  final double spacing;
  final double fontSize;
  final FontWeight fontWeight;
  final Color borderColor;
  final Color textColor;

  const VerifiedBadge({
    Key? key,
    this.paddingHorizontal = 12.0,
    this.paddingVertical = 6.0,
    this.borderRadius = 7.0,
    this.iconSize = 16.0,
    this.spacing = 4.0,
    this.fontSize = 13.0,
    this.fontWeight = FontWeight.w600,
    this.borderColor = const Color(0xFF2477E1),
    this.textColor = const Color(0xFF2477E1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isRTL
            ? [
                Flexible(
                  child: Text(
                    localizations.translate('Verified'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing),
                Container(
                  width: iconSize,
                  height: iconSize,
                  child: SvgPicture.asset(
                    'assets/Icons/Verified.svg', // Fixed path to your icon asset
                    fit: BoxFit.contain,
                  ),
                ),
              ]
            : [
                Container(
                  width: iconSize,
                  height: iconSize,
                  child: SvgPicture.asset(
                    'assets/Icons/Verified.svg', // Fixed path to your icon asset
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: spacing),
                Flexible(
                  child: Text(
                    localizations.translate('Verified'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
      ),
    );
  }
}
