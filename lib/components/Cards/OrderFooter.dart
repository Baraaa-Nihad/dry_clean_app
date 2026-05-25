import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import the localization utility

class OrderFooter extends StatelessWidget {
  final OrderData order;

  const OrderFooter({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Get the localization instance
    ValidationUtils validationUtils = ValidationUtils();

    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                localizations.translate('total'),
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      height: 0,
                      color: AppColors.gray60),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '₪${order.totalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      height: 0,
                      color: AppColors.gray70),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${localizations.translate('order')} ${validationUtils.formatOrderId(order.orderId)}',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      height: 0,
                      color: AppColors.gray50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
