import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Basket/basket_card.dart';
import 'package:saleem_dry_clean/components/Basket/basket_item.dart';
import 'package:saleem_dry_clean/components/Basket/category_section.dart';
import 'package:saleem_dry_clean/components/Basket/serviceType_section.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ItemListModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final List<BasketItemData> items = orderProvider.cart;
    final localizations = AppLocalizations.of(context);

    // Group items by category and service type
    final groupedData = groupItemsByCategoryAndServiceType(items);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/vectors/close_icon.svg',
                  width: 48.0,
                  height: 48.0,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
              Text(
                localizations.translate('items_details'),
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.bold16Gray80(context).copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Spacer(flex: 2), // To center the title
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groupedData.length,
            itemBuilder: (context, index) {
              String category = groupedData.keys.elementAt(index);
              Map<String, List<BasketItemData>> serviceTypes =
                  groupedData[category]!;
              bool isFirstCategory = false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategorySection(
                    title: category,
                    fem: 1,
                    isFirst: isFirstCategory,
                  ),
                  ...serviceTypes.entries.map((serviceTypeEntry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ServiceTypeSection(
                          serviceType: serviceTypeEntry.key,
                          fem: 1,
                        ),
                        BasketCard(
                          items: serviceTypeEntry.value.map((item) {
                            return BasketItem(
                              label: item.subCategory,
                              imagePath: item.imagePath,
                              price: item.price,
                              isDeletable: false, // This item cannot be deleted
                              unit: item.unit,
                              quantity: item.quantity,
                              fem: 1,
                              serviceType: item.serviceType
                                  .serviceName, // Ensure this is a string
                              subCategory: item.subCategory,
                              onDelete: () {
                                orderProvider.removeProduct(item);
                              },
                            );
                          }).toList(),
                          fem: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, Map<String, List<BasketItemData>>>
      groupItemsByCategoryAndServiceType(List<BasketItemData> items) {
    final Map<String, Map<String, List<BasketItemData>>> groupedData = {};

    for (var item in items) {
      if (!groupedData.containsKey(item.category)) {
        groupedData[item.category] = {};
      }
      String serviceKey =
          item.serviceType.serviceName; // Use serviceName or service.id
      if (!groupedData[item.category]!.containsKey(serviceKey)) {
        groupedData[item.category]![serviceKey] = [];
      }
      groupedData[item.category]![serviceKey]!.add(item);
    }

    return groupedData;
  }
}
