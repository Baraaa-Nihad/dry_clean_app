import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class OrderDetails extends StatelessWidget {
  final OrderData order;

  const OrderDetails({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Get the localization instance
    ValidationUtils validationUtils = ValidationUtils();

    print(order.createdAt);
    // Ensure date formatting and handle null cases
    String formattedOrderedAt = order.orderedAt != null
        ? validationUtils.formatGeneralDateTime(order.createdAt.toString())
        : localizations.translate('noDateAvailable') ?? 'No Date Available';

    String formattedCollectionTime = order.collectionTime ??
        localizations.translate('noCollectionTime') ??
        'No Collection Time';

    String formattedDeliveryTime = order.deliveryTime ??
        localizations.translate('noDeliveryTime') ??
        'No Delivery Time';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: AppColors.gray20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _buildInfoRow(
                context, localizations.translate('location'), order.location),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            child: Divider(
              color: AppColors.gray20,
              thickness: 1,
              height: 1,
            ),
          ),
          _buildInfoRow(context, localizations.translate('ordered_at'),
              formattedOrderedAt),
          _buildInfoRow(context, localizations.translate('collection_time'),
              formattedCollectionTime),
          _buildInfoRow(context, localizations.translate('delivery_time'),
              formattedDeliveryTime),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray60,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            // Use Flexible to give value text enough room
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray70,
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
