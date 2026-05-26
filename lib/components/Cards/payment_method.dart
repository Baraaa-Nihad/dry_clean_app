import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import the localization utility

class PaymentMethod extends StatelessWidget {
  final String paymentMethod;
  final bool isPaid;
  final bool showLabel;

  const PaymentMethod({
    Key? key,
    required this.paymentMethod,
    this.isPaid = false,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Get the localization instance
    return Container(
      width: double.infinity, // Make the container full width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          top: BorderSide(width: 1, color: Color(0xFFE5EAF6)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  localizations.translate('payment_method'),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: AppColors.gray80),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset('assets/Icons/Cash.svg'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.translate(paymentMethod),
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          height: 0,
                          color: AppColors.gray50),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showLabel)
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: 100,
              height: 100,
              child: SvgPicture.asset(
                isPaid ? 'assets/Icons/Paid.svg' : 'assets/Icons/Unpaid.svg',
              ),
            ),
        ],
      ),
    );
  }
}
