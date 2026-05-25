import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Basket/basket_card.dart';
import 'package:saleem_dry_clean/components/Basket/basket_item.dart';
import 'package:saleem_dry_clean/components/Basket/category_section.dart';
import 'package:saleem_dry_clean/components/Basket/serviceType_section.dart';
import 'package:saleem_dry_clean/components/Modals/DeleteModal.dart';
import 'package:saleem_dry_clean/components/EmptyPage/EmptyPage.dart';
import 'package:saleem_dry_clean/screens/Receipt/OrderReceiptPage.dart';
import 'package:saleem_dry_clean/screens/Receipt/ReceiptContainer.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Models/OrderItem.dart';
import 'package:saleem_dry_clean/services/Models/Service.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class OrderBasketDetails extends StatelessWidget {
  final OrderData order;

  const OrderBasketDetails({
    Key? key,
    required this.order,
  }) : super(key: key);

  // Convert OrderItem to BasketItemData
  List<BasketItemData> convertOrderItemsToBasketItems(
      List<OrderItem> orderItems) {
    return orderItems.map((orderItem) {
      return BasketItemData(
        productId: orderItem.orderId, // Assuming this is the product ID
        productName: orderItem.productName,
        category: orderItem.category,
        serviceType: Service(
          id: orderItem.orderId,
          serviceName: orderItem.serviceType,
          price: '...',
        ), // Convert serviceType string to a Service object
        imagePath: orderItem.imagePath,
        price: orderItem.unitPrice,
        unit: 'unit', // Placeholder for unit, modify based on your data
        quantity: orderItem.quantity,
        subCategory: orderItem.serviceName,
        subtotal: orderItem.total, // Assuming total is already calculated
      );
    }).toList();
  }

  // Group the items by category and service type, using the order's items
  Map<String, Map<String, List<BasketItemData>>>
      groupItemsByCategoryAndServiceType(List<BasketItemData> items) {
    final Map<String, Map<String, List<BasketItemData>>> groupedData = {};

    for (var item in items) {
      if (!groupedData.containsKey(item.category)) {
        groupedData[item.category] = {};
      }
      String serviceKey = item.serviceType.serviceName;
      if (!groupedData[item.category]!.containsKey(serviceKey)) {
        groupedData[item.category]![serviceKey] = [];
      }
      groupedData[item.category]![serviceKey]!.add(item);
    }

    return groupedData;
  }

  /// Handle basket tap with navigation
  Future<void> _handleBackTap(BuildContext context) async {
    try {
      // Navigate to the main route and remove all previous routes
      NavigatorService.navigateToAndRemoveUntil(RouteNames.main);

      // After navigation, set the selected index in NavigationProvider
      await Future.delayed(Duration(milliseconds: 100), () {
        Provider.of<NavigationProvider>(context, listen: false)
            .setSelectedIndex(2); // Setting index 2 (for Orders)
      });
    } catch (error) {
      debugPrint('Error during basket navigation: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while navigating to the basket.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final double fem = 1; // Assuming a base width of 375 for scaling
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // Convert OrderItems to BasketItemData and group them
    final groupedData = groupItemsByCategoryAndServiceType(
      convertOrderItemsToBasketItems(order.items),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppHeader(
          prefixIcon: BackButtonWidget(
            onTap: () {
              _handleBackTap(context);
            },
          ),
          quantityNumber: true,
          title: localizations?.translate('items_details') ?? 'Items details',
          fem: fem,
        ),
        backgroundColor: AppColors.white,
        body: order.items.isEmpty
            ? EmptyPage(
                fem: fem,
                iconUrl: 'assets/Icons/EmptyBasketIcon.svg',
                title: localizations.translate("no_items_yet"),
                subtitle: localizations.translate("no_items_basket_message"),
                showButton: true,
                buttonAction: () {
                  Navigator.pop(context);
                },
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
                        bool isFirstCategory = false;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderReceiptPage(
                                      tokenService: Provider.of<TokenService>(
                                          context,
                                          listen: false),

                                      order:
                                          order, // Ensure the 'order' object is available and passed correctly
                                    ),
                                  ),
                                );
                              },
                              child: ReceiptContainer(),
                            ),
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
                                        .value.first.serviceType.serviceName,
                                    fem: fem,
                                  ),
                                  BasketCard(
                                    items: serviceTypeEntry.value.map((item) {
                                      return BasketItem(
                                        label: item.productName,
                                        imagePath: item.imagePath,
                                        price: item.price,
                                        unit: item.unit,
                                        quantity: item.quantity,
                                        fem: fem,
                                        isDeletable: false,
                                        serviceType:
                                            item.serviceType.serviceName,
                                        subCategory: item.subCategory,
                                        onDelete: () {
                                          _showDeleteModal(context, item, fem);
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
                  ),
                ],
              ),
      ),
    );
  }

  void _showDeleteModal(BuildContext context, BasketItemData item, double fem) {
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
        // Here you could remove the item from the order if needed
      },
      fem: fem,
    );
  }
}
