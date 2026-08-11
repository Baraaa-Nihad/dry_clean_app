import 'package:saleem_dry_clean/ui.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class PaymentDetails extends StatelessWidget {
  final OrderData order;

  const PaymentDetails({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('paymentDetails'),
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                height: 0,
                color: AppColors.gray80,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (order.hasPendingMeasurement)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE3B3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: Color(0xFFE9A328)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.translate(
                        'final_price_after_collection_measurement',
                      ),
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.sfarabicMedium.copyWith(
                          fontSize: 12.5,
                          color: const Color(0xFFB97812),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentRow(
                context,
                localizations.translate('orderAmount'),
                order.subtotal,
                isTotal: false,
              ),
              const SizedBox(height: 4),
              _buildPaymentRow(
                context,
                localizations.translate('deliveryCost'),
                order.deliveryFees.toStringAsFixed(2), // Ensure formatting
                isTotal: false,
              ),
              const SizedBox(height: 4),
              _buildPaymentRow(
                context,
                localizations.translate('total'),
                order.totalPrice.toStringAsFixed(2),
                isTotal: true,
                isPaid: !order.isPaid,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, String label, String amount,
      {bool isTotal = false, bool isPaid = false}) {
    return Container(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray60(context).copyWith(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
                height: 1.0, // Adjust height if necessary
                color: AppColors.gray60, // Text color for the label
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '₪',
                textAlign: TextAlign.center,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                    height: 1.0, // Adjust height if necessary
                    color: isTotal
                        ? (!isPaid
                            ? AppColors.statusGreen
                            : AppColors.statusRed)
                        : AppColors.gray70,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                amount,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                    height: 1.0, // Adjust height if necessary
                    color: isTotal
                        ? (!isPaid
                            ? AppColors.statusGreen
                            : AppColors.statusRed)
                        : AppColors.gray70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
