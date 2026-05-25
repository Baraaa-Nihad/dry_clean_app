import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import the localization utility

class PaymentDetails extends StatelessWidget {
  final double subTotal;
  final double deliveryFees;
  final double total;

  const PaymentDetails({
    Key? key,
    required this.subTotal,
    required this.deliveryFees,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Get the localization instance

    return Container(
      width: 428,
      height: 167,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  localizations.translate('payment_details'),
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray70),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow(
                  context, localizations.translate('sub_total'), subTotal),
              const SizedBox(height: 8),
              buildDetailRow(context, localizations.translate('delivery_fees'),
                  deliveryFees),
              const SizedBox(height: 4),
              buildDetailRow(context, localizations.translate('total'), total,
                  isTotal: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(BuildContext context, String title, double amount,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              height: 0,
              color: isTotal ? Color(0xFF02295A) : AppColors.gray50,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₪',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: isTotal ? Color(0xFF033371) : AppColors.gray50,
                ),
              ),
            ),
            Text(
              amount.toStringAsFixed(2),
              style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                    color: isTotal ? Color(0xFF033371) : AppColors.gray50,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
