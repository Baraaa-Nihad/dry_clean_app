import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Cards/ItemListModalContent.dart';
import 'package:saleem_dry_clean/components/GradientText.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Notification/QuantityIcon.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ImageLoader.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import localization utility

class ItemSummary extends StatelessWidget {
  final int itemCount;
  final List<Map<String, dynamic>> items;

  const ItemSummary({
    Key? key,
    required this.itemCount,
    required this.items,
  }) : super(key: key);

  void showAllItemsModal(
      BuildContext context, List<Map<String, dynamic>> items) {
    BlankModal.show(
      context,
      isDismissible: false, // Make modal dismissible
      1, // Example padding, can be adjusted or made dynamic
      ItemListModalContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Get localization instance
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations
                      ?.translate('items')
                      ?.replaceFirst('%d', '$itemCount') ??
                  'Items ($itemCount)', // Translate "Items"
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    height: 0,
                    color: AppColors.gray70),
              ),
            ),
            GestureDetector(
              onTap: () {
                showAllItemsModal(context, items);
              },
              child: Row(
                children: [
                  GradientText(
                    text: localizations?.translate('show_all') ??
                        'Show all', // Translate "Show all"
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.bold16GradientSmall(context).copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          height: 0,
                          color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      isRtl
                          ? 'assets/Icons/ArrowRtl.svg'
                          : 'assets/Icons/RightGradenatArrow.svg',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: isRtl,
          child: Row(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    ImageLoader(
                      imageUrl: item['imageUrl'],
                      height: 50,
                      width: 48,
                      borderRadius: 12,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: QuantityIcon(
                        size: IconSize.small,
                        quantity: item['quantity'],
                        color: AppColors.gray70,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
