import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Cards/CollectionDelivery.dart';
import 'package:saleem_dry_clean/components/Cards/ItemSummary.dart';
import 'package:saleem_dry_clean/components/Cards/PaymentDetails.dart';
import 'package:saleem_dry_clean/components/Cards/payment_method.dart';
import 'package:saleem_dry_clean/components/Checkout/promo_and_note_section.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/services/Providers/DryCleanProvider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class OrdersSummary extends StatelessWidget {
  final VoidCallback EditLocationButton;
  final VoidCallback EditTimeButton;

  const OrdersSummary({
    Key? key,
    required this.EditLocationButton,
    required this.EditTimeButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isArabic = localizations.locale.languageCode == 'ar';

    return Consumer2<OrderProvider, DryCleanProvider>(
      builder: (context, orderProvider, dryCleanProvider, child) {
        if (orderProvider.cart.isEmpty) {
          return Center(
            child: LoadingDots(fem: 1),
          );
        }

        // Create an instance of ValidationUtils
        ValidationUtils validationUtils = ValidationUtils();

        String formattedCollectionDate = (orderProvider.collectionDay ?? '') +
            " " +
            validationUtils.formatDateTime(
              orderProvider.collectionDate ?? '',
            );

        String formattedDeliveryDate = (orderProvider.deliveryDay ?? '') +
            " " +
            validationUtils.formatDateTime(
              orderProvider.deliveryDate ?? '',
            );
        String addressName = isArabic
            ? (orderProvider.address?['addressName_ar'] ?? 'Unknown Address')
            : (orderProvider.address?['addressName_en'] ?? 'Unknown Address');
        return Scaffold(
          body: Container(
            color: AppColors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // اسم المغسلة بوضوح (٢.١.٤).
                  //
                  // آخر شاشة قبل الدفع هي آخر فرصة للزبون كي يكتشف أنه
                  // في المحل الخطأ. وقد اختاره قبل عدّة شاشات.
                  if (orderProvider.storeName != null)
                    _StoreLine(name: orderProvider.storeName!),
                  CollectionDelivery(
                    location: addressName,
                    collectionTime: orderProvider.pickupTime ?? 'Not set',
                    deliveryTime: orderProvider.deliveryTime ?? 'Not set',
                    formattedDeliveryDate: formattedDeliveryDate,
                    formattedCollectionDate: formattedCollectionDate,
                    onEditLocation: EditLocationButton,
                    onEditTime: EditTimeButton,
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(color: Colors.white),
                    child: ItemSummary(
                      itemCount: orderProvider.totalQuantity,
                      items: orderProvider.cart.map((item) {
                        return {
                          'imageUrl': item.imagePath ??
                              'https://via.placeholder.com/48x50',
                          'quantity': item.quantity,
                        };
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 6),
                  // كود الخصم وملاحظة الزبون (٢.١.٤)
                  const PromoAndNoteSection(),
                  SizedBox(height: 6),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PaymentDetails(
                          subTotal: orderProvider.subtotal,
                          deliveryFees:
                              dryCleanProvider.dryClean?.deliveryFees ?? 0.0,
                          total: orderProvider.total,
                        ),
                        // سطر الخصم يظهر فقط عند وجوده: صفر معروض يجعل
                        // الزبون يبحث عن خصم لم يطلبه
                        if (orderProvider.discount > 0)
                          _DiscountLine(
                            code: orderProvider.promoCode ?? '',
                            amount: orderProvider.discount,
                          ),
                        PaymentMethod(
                          paymentMethod:
                              localizations.translate('cash on delivery'),
                          showLabel: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 135),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// اسم المغسلة أعلى الملخّص.
class _StoreLine extends StatelessWidget {
  const _StoreLine({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined,
                size: 20, color: AppColors.green),
            const SizedBox(width: 9),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.sfarabicRegular.copyWith(
                      fontSize: 13.5, color: AppColors.secondaryTextColor),
                  children: [
                    const TextSpan(text: 'طلبك من '),
                    TextSpan(
                      text: name,
                      style: AppTextStyles.sfarabicBold
                          .copyWith(fontSize: 14.5, color: AppColors.gray80),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

/// سطر الخصم أسفل تفاصيل الدفع.
class _DiscountLine extends StatelessWidget {
  const _DiscountLine({required this.code, required this.amount});
  final String code;
  final double amount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                code.isEmpty ? 'الخصم' : 'الخصم ($code)',
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 13.5, color: AppColors.green),
              ),
            ),
            Text(
              '− ${amount.toStringAsFixed(2)}₪',
              style: AppTextStyles.poppinsSemiBold
                  .copyWith(fontSize: 14, color: AppColors.green),
            ),
          ],
        ),
      );
}
