import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import your localization file

class OrderTable extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const OrderTable({Key? key, required this.title, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.gray80),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFF9F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFE5EAF6),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5EAF6), width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 151,
                        child: Text(
                          localizations.translate('itemsTitle'),
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                height: 2.1,
                                color: AppColors.gray80),
                          ),
                        ),
                      ),
                      Container(
                        width: 62,
                        child: Text(
                          localizations.translate('price'),
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                height: 2.1,
                                color: AppColors.gray80),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        width: 40,
                        child: Text(
                          localizations.translate('Qty'),
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                height: 2.1,
                                color: AppColors.gray80),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        width: 62,
                        child: Text(
                          localizations.translate('Total'),
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                height: 2.1,
                                color: AppColors.gray80),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                ...items.map((item) {
                  String name = item['name'];
                  int qty = item['qty'];
                  double price = item['price'];
                  double total = price * qty;
                  return _buildOrderItem(name, price, qty, total, context);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
      String name, double price, int qty, double total, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 32, // Set the row height to 32
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 151,
            child: Text(
              name,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    height: 2.25,
                    color: AppColors.gray60),
              ),
            ),
          ),
          Container(
            width: 62,
            alignment: Alignment.centerRight,
            child: Text(
              '₪${price.toStringAsFixed(2)}',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.gray70),
              ),
            ),
          ),
          Container(
            width: 25,
            alignment: Alignment.centerRight,
            child: Text(
              qty.toString(),
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.gray70),
              ),
            ),
          ),
          Container(
            width: 62,
            alignment: Alignment.centerRight,
            child: Text(
              '₪${total.toStringAsFixed(2)}',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.gray70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
