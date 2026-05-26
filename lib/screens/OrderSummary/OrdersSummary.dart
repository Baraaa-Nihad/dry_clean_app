import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Cards/CollectionDelivery.dart';
import 'package:saleem_dry_clean/components/Cards/ItemSummary.dart';
import 'package:saleem_dry_clean/components/Cards/PaymentDetails.dart';
import 'package:saleem_dry_clean/components/Cards/payment_method.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
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
