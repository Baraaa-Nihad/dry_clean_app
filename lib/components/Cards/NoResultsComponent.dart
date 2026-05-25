import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class NoResultsComponent extends StatelessWidget {
  final String message;

  const NoResultsComponent({
    Key? key,
    this.message = 'no_results_message',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 170.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Move the content slightly up by reducing the space above it
          SizedBox(height: 16.h), // Adjust top space
          Container(
            width: 40.w, // Adjust icon size to be responsive
            height: 40.h,
            decoration: ShapeDecoration(
              color: Color(0xFFF9F9FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r),
              ),
            ),
            child: SvgPicture.asset(
              'assets/Icons/solidError.svg',
              width: 24.w,
              height: 24.h,
            ),
          ),
          SizedBox(height: 16.h), // Adjust space between the icon and the text
          SizedBox(
            width: double.infinity,
            child: Text(
              localizations.translate(message),
              textAlign: TextAlign.center,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 14.sp, // Make font size responsive
                    fontWeight: FontWeight.w600,
                    height: 1.5, // Adjust text height
                    color: AppColors.gray60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
