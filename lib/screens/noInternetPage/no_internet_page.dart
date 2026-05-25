// lib/screens/NoInternetPage/no_internet_modal_content.dart

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class NoInternetModalContent extends StatelessWidget {
  final double fem;
  final VoidCallback onRetry;

  const NoInternetModalContent({
    Key? key,
    required this.fem,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: 428 * fem,
      height: 800 * fem,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * fem),
        border: Border.all(
          color: Color(0xFF00E213),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 14,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: 380 * fem,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 182 * fem,
                    height: 182 * fem,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Color(0xFFF9F9FF),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.14 * fem,
                          color: Color(0xFFE5EAF6),
                        ),
                        borderRadius: BorderRadius.circular(200 * fem),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 42 * fem,
                          top: 42 * fem,
                          child: Container(
                            width: 98 * fem,
                            height: 98 * fem,
                            child: Stack(),
                          ),
                        ),
                        Positioned(
                          left: 116 * fem,
                          top: 63 * fem,
                          child: Container(
                            width: 19 * fem,
                            height: 19 * fem,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * fem),
                  Container(
                    width: double.infinity,
                    height: 56 * fem,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Oops! No Internet',
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray70,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8 * fem),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Please check your connection.',
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray50,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30 * fem),
                  LoadingButton(
                    buttonWidth: "large",
                    fem: fem,
                    buttonText:
                        '${localizations?.translate('Retry') ?? 'Retry'}',
                    onPressed: onRetry, // Use the onRetry callback
                  ),
                  SizedBox(height: 20 * fem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
