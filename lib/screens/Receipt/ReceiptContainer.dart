import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ReceiptContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the layout is RTL
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);

    return Container(
      width: 380,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.gray10,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppColors.gray20),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: SvgPicture.asset(
                            'assets/Icons/receipt.svg', // Replace with your receipt icon
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.translate('Receipt') ?? 'Receipt',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          height: 0,
                          color: AppColors.gray80),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 24,
            height: 24,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(),
            // Display the appropriate arrow icon based on the RTL setting
            child: SvgPicture.asset(
              isRtl
                  ? 'assets/Icons/arrow_left.svg' // Arrow pointing left for RTL
                  : 'assets/Icons/rightSmallArrow.svg', // Arrow pointing right for LTR
            ),
          ),
        ],
      ),
    );
  }
}
