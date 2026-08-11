// lib/screens/BasketPage/BasketPage.dart

import 'package:saleem_dry_clean/ui.dart';
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
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class BasketPage extends StatelessWidget {
  final double fem;

  const BasketPage({Key? key, required this.fem}) : super(key: key);

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
    final userProvider = context.watch<UserProvider>();
    final groupedData = groupItemsByCategoryAndServiceType(orderProvider.cart);
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppHeader(
          quantityNumber: true,
          title: localizations.translate('basket'),
          fem: fem,
          suffixIcon: userProvider.userSignedIn
              ? const NotificationButton()
              : null,
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
                buttonAction: () => Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                ).setSelectedIndex(0),
                buttonText: localizations.translate("add_items_now"),
              )
            : Column(
                children: [
                  // اسم المغسلة فوق السلّة.
                  //
                  // الزبون قد يملأ سلّته ثم يتصفّح مغاسل أخرى ويعود. وبلا
                  // هذا السطر لا شيء في الشاشة يقول من سيغسل — ويكتشفه
                  // بعد الدفع.
                  if (orderProvider.storeName != null)
                    _StoreBanner(fem: fem, storeName: orderProvider.storeName!),
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
                                        serviceType: item
                                            .serviceType
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
                          color: AppColors.gray60.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: CheckoutSection(
                      fem: fem,
                      price: orderProvider.subtotal,
                      itemCount: orderProvider.totalQuantity,
                      pricePending: orderProvider.hasPendingMeasurement,
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
      mainTitle: localizations.translate('delete_item'),
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

/// شريط اسم المغسلة أعلى السلّة.
class _StoreBanner extends StatelessWidget {
  const _StoreBanner({required this.fem, required this.storeName});

  final double fem;
  final String storeName;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    const translationKey = 'basket_order_from';
    final translated = localizations.translate(translationKey);
    final template = translated == translationKey
        ? (Localizations.localeOf(context).languageCode == 'ar'
              ? 'طلبك من {store}'
              : 'Your order from {store}')
        : translated;
    final markerIndex = template.indexOf('{store}');
    final beforeStore = markerIndex < 0
        ? '$template '
        : template.substring(0, markerIndex);
    final afterStore = markerIndex < 0
        ? ''
        : template.substring(markerIndex + '{store}'.length);

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 24 * fem, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 19,
            color: AppColors.brandAccent,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              textDirection: Directionality.of(context),
              textAlign: TextAlign.start,
              text: TextSpan(
                style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 13,
                  color: AppColors.secondaryTextColor,
                ),
                children: [
                  TextSpan(text: beforeStore),
                  TextSpan(
                    text: storeName,
                    style: AppTextStyles.sfarabicBold.copyWith(
                      fontSize: 13.5,
                      color: AppColors.gray80,
                    ),
                  ),
                  if (afterStore.isNotEmpty) TextSpan(text: afterStore),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
