import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Modals/ItemDetailsModalContent.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Models/Service.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class BlankCategoryModal extends StatefulWidget {
  final String mainTitle;
  final String subTitle;
  final String imagePath;
  final String pricePerUnit;
  final String? prefixIconPath;
  final String? suffixIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final double fem;
  final bool isDisabledButton;
  final String area;
  final Map<String, Map<String, dynamic>> services;

  const BlankCategoryModal({
    Key? key,
    required this.mainTitle,
    required this.subTitle,
    required this.imagePath,
    required this.pricePerUnit,
    this.prefixIconPath,
    this.suffixIconPath,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    required this.fem,
    required this.area,
    required this.isDisabledButton,
    required this.services,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String mainTitle,
    required String subTitle,
    required String imagePath,
    required String pricePerUnit,
    String? prefixIconPath,
    String? suffixIconPath,
    VoidCallback? onPrefixIconTap,
    VoidCallback? onSuffixIconTap,
    required double fem,
    required String area,
    required bool isDisabledButton,
    required Map<String, Map<String, dynamic>> services,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlankCategoryModal(
        mainTitle: mainTitle,
        subTitle: subTitle,
        imagePath: imagePath,
        pricePerUnit: pricePerUnit,
        prefixIconPath: prefixIconPath,
        suffixIconPath: suffixIconPath,
        onPrefixIconTap: onPrefixIconTap,
        onSuffixIconTap: onSuffixIconTap,
        fem: fem,
        isDisabledButton: isDisabledButton,
        services: services,
        area: area,
      ),
    );
  }

  @override
  _BlankCategoryModalState createState() => _BlankCategoryModalState();
}

class _BlankCategoryModalState extends State<BlankCategoryModal> {
  int totalQuantity = 0;
  bool isDisabledButton = true;
  Map<String, int> serviceQuantities = {};

  @override
  void initState() {
    super.initState();
    isDisabledButton = widget.isDisabledButton;
    widget.services.forEach((service, details) {
      serviceQuantities[service] = 0;
    });
  }

  void _updateTotalQuantity(int quantityChange, String serviceName) {
    setState(() {
      totalQuantity += quantityChange;
      serviceQuantities[serviceName] =
          serviceQuantities[serviceName]! + quantityChange;
      isDisabledButton = totalQuantity <= 0;
    });
  }

  void _handleAddToBasket() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    widget.services.forEach((service, details) {
      int quantity = serviceQuantities[service] ?? 0;
      if (quantity > 0) {
        final int? productId = details['productId'] as int?;
        final String? productName = details['productName'] as String?;
        final double price = (details['price'] as double?) ?? 0.0;

        final int serviceTypeId = details['serviceTypeId'] as int;
        final String serviceTypeName = service as String? ?? 'Unknown Service';
        final String serviceTypePrice = details['price']?.toString() ?? '0';

        if (productId != null && productName != null) {
          BasketItemData item = BasketItemData(
            productId: productId,
            productName: productName,
            category: widget.mainTitle,
            serviceType: Service(
                id: serviceTypeId,
                price: serviceTypePrice,
                serviceName: serviceTypeName),
            imagePath: widget.imagePath,
            price: price,
            unit: details['unit'],
            quantity: quantity,
            subCategory: widget.subTitle,
            area: widget.area,
            subtotal: 0.0,
          );
          orderProvider.addProduct(item);
        } else {
          print('Error: productId or productName is null for service $service');
        }
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على الـ bottom inset (safe area على iPhone)
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    // ارتفاع المودال = كامل الشاشة - 56 - safe area
    final double modalHeight =
        MediaQuery.of(context).size.height - 56 - bottomInset;
    final localizations = AppLocalizations.of(context);

    return Padding(
      // هذا يرفع المودال بمقدار الـ safe area تلقائياً على iPhone
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: modalHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.green, width: 2),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(16 * widget.fem),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 70 * widget.fem),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * widget.fem),
                    Stack(
                      children: [
                        if (widget.prefixIconPath != null)
                          PositionedDirectional(
                            start: 0,
                            child: GestureDetector(
                              onTap: widget.onPrefixIconTap,
                              child: SvgPicture.asset(
                                widget.prefixIconPath!,
                                width: 48 * widget.fem,
                                height: 48 * widget.fem,
                              ),
                            ),
                          ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.mainTitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    color: AppColors.gray70,
                                  ),
                                ),
                              ),
                              Text(
                                widget.subTitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    color: AppColors.gray70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.suffixIconPath != null)
                          PositionedDirectional(
                            end: 0,
                            child: GestureDetector(
                              onTap: widget.onSuffixIconTap,
                              child: SvgPicture.asset(
                                widget.suffixIconPath!,
                                width: 24 * widget.fem,
                                height: 24 * widget.fem,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16 * widget.fem),
                    ItemDetailsModalContent(
                      pricePerUnit: widget.pricePerUnit,
                      fem: widget.fem,
                      services: widget.services,
                      onValueChange: _updateTotalQuantity,
                      imagePath: widget.imagePath,
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 16 * widget.fem,
              start: 12 * widget.fem,
              end: 12 * widget.fem,
              child: PrimaryButton(
                fem: 1,
                isDisabled: isDisabledButton,
                text: localizations
                    .translate('add_to_basket')
                    .replaceFirst('%d', '$totalQuantity'),
                onPressed: _handleAddToBasket,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
