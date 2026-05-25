// lib/screens/BasketPage/BasketPage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/Basket/basket_card.dart';
import 'package:saleem_dry_clean/components/Basket/basket_item.dart';
import 'package:saleem_dry_clean/components/Basket/category_section.dart';
import 'package:saleem_dry_clean/components/Basket/checkout_section.dart';
import 'package:saleem_dry_clean/components/Basket/serviceType_section.dart';
import 'package:saleem_dry_clean/components/Modals/DeleteModal.dart';
import 'package:saleem_dry_clean/components/EmptyPage/EmptyPage.dart';
import 'package:saleem_dry_clean/components/Notification/NotificationButton.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/Providers/AddressesProvider.dart'; // Import AddressesProvider
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class BasketPage extends StatelessWidget {
  final double fem;

  const BasketPage({
    Key? key,
    required this.fem,
  }) : super(key: key);

  Map<String, Map<String, List<BasketItemData>>>
      groupItemsByCategoryAndServiceType(List<BasketItemData> items) {
    final Map<String, Map<String, List<BasketItemData>>> groupedData = {};

    for (var item in items) {
      if (!groupedData.containsKey(item.category)) {
        groupedData[item.category] = {};
      }
      String serviceKey =
          item.serviceType.serviceName; // Correct access to serviceName
      if (!groupedData[item.category]!.containsKey(serviceKey)) {
        groupedData[item.category]![serviceKey] = [];
      }
      groupedData[item.category]![serviceKey]!.add(item);
    }

    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final addressesProvider = Provider.of<AddressesProvider>(context,
        listen: false); // Access AddressesProvider
    final groupedData = groupItemsByCategoryAndServiceType(orderProvider.cart);
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppHeader(
          quantityNumber: true,
          title: localizations?.translate('basket') ?? 'Basket',
          fem: fem,
          suffixIcon: NotificationButton(),
          onPrefixIconTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.gray10,
        body: orderProvider.cart.isEmpty
            ? EmptyPage(
                fem: fem,
                iconUrl: 'assets/Icons/EmptyBasketIcon.svg',
                title: localizations.translate("no_items_yet"),
                subtitle: localizations.translate("no_items_basket_message"),
                showButton: true,
                buttonAction: () =>
                    Provider.of<NavigationProvider>(context, listen: false)
                        .setSelectedIndex(0),
                buttonText: localizations.translate("add_items_now"),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24 * fem),
                      itemCount: groupedData.length,
                      itemBuilder: (context, index) {
                        String category = groupedData.keys.elementAt(index);
                        Map<String, List<BasketItemData>> serviceTypes =
                            groupedData[category]!;
                        bool isFirstCategory = index == 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategorySection(
                              title: category,
                              fem: fem,
                              isFirst: isFirstCategory,
                            ),
                            ...serviceTypes.entries.map((serviceTypeEntry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ServiceTypeSection(
                                    serviceType: serviceTypeEntry
                                        .value
                                        .first
                                        .serviceType
                                        .serviceName, // Correct access to serviceName
                                    fem: fem,
                                  ),
                                  BasketCard(
                                    items: serviceTypeEntry.value.map((item) {
                                      return BasketItem(
                                        label: item.subCategory,
                                        imagePath: item.imagePath,
                                        price: item.price,
                                        unit: item.unit,
                                        quantity: item.quantity,
                                        fem: fem,
                                        serviceType: item.serviceType
                                            .serviceName, // Correct access to serviceName
                                        subCategory: item.subCategory,
                                        onDelete: () {
                                          _showDeleteModal(context, item);
                                        },
                                      );
                                    }).toList(),
                                    fem: fem,
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray60.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: CheckoutSection(
                      fem: fem,
                      price: orderProvider.subtotal,
                      itemCount: orderProvider.totalQuantity,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showDeleteModal(BuildContext context, BasketItemData item) {
    final localizations = AppLocalizations.of(context);

    DeleteModal.show(
      context,
      mainTitle: localizations?.translate('delete_item') ?? 'Delete item?',
      richBody: '${item.quantity} ${item.subCategory}',
      prefixIconPath: 'assets/vectors/close_icon.svg',
      onPrefixIconTap: () {
        Navigator.of(context).pop();
      },
      onDelete: () {
        Navigator.of(context).pop();
        Provider.of<OrderProvider>(context, listen: false).removeProduct(item);
      },
      fem: fem,
    );
  }
}
