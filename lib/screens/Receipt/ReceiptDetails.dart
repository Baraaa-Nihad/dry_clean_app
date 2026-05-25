import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Tables/OrderTable.dart';
import 'package:saleem_dry_clean/services/Models/OrderItem.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import your localization file

class ReceiptDetails extends StatelessWidget {
  final OrderData order;

  const ReceiptDetails({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the localization instance
    final localizations = AppLocalizations.of(context);
    ValidationUtils validationUtils = ValidationUtils();

    // Get the categorized items
    Map<String, List<OrderItem>> categorizedItems = order.itemsByCategory();
    // Determine which date to display, prioritize createdAt, fallback to orderedAt
    final DateTime? orderCreateDate = order.createdAt != null
        ? order.createdAt
        : DateTime.tryParse(order.orderedAt); // Parsing if orderedAt is String

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations?.translate('orderDetails') ?? 'Order Details',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: AppColors.gray80),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                orderCreateDate != null
                    ? validationUtils
                        .formatGeneralDateTime(orderCreateDate.toString())
                    : localizations?.translate('noDateAvailable') ??
                        'No Date Available',
                style: AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray50,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Iterating over the categorized items map to display each category
          ...categorizedItems.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderTable(
                  title: entry.key, // Title for the items table
                  items: entry.value.map((item) {
                    return {
                      'name': item.productName,
                      'qty': item.quantity,
                      'price': item.unitPrice,
                      'total': item.total,
                      // 'picture': item.imagePath ?? 'default_image_path',
                      'was_missed': item.wasMissed ? 'Yes' : 'No',
                    };
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
