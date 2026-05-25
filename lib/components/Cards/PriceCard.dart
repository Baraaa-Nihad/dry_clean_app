import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class PriceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '₪8.00',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.bold16Gray80(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue),
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.bold16Gray80(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray50),
                    ),
                  ),
                  TextSpan(
                    text: '/Square meter',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray40),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
