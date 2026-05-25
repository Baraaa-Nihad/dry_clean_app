import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CollectionDelivery extends StatelessWidget {
  final String location;
  final String collectionTime;
  final String deliveryTime;
  final String formattedDeliveryDate;
  final String formattedCollectionDate;
  final VoidCallback onEditLocation;
  final VoidCallback onEditTime;

  const CollectionDelivery({
    Key? key,
    required this.location,
    required this.collectionTime,
    required this.deliveryTime,
    required this.formattedDeliveryDate,
    required this.formattedCollectionDate,
    required this.onEditLocation,
    required this.onEditTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: 428,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.translate('collection_and_delivery') ??
                'Collection and delivery',
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  height: 0,
                  color: AppColors.gray80),
            ),
          ),
          const SizedBox(height: 12),
          buildLocationCard(context, localizations),
          const SizedBox(height: 12),
          buildCombinedTimeCard(context, localizations),
        ],
      ),
    );
  }

  Widget buildLocationCard(
      BuildContext context, AppLocalizations? localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFE5EAF6)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            child: SvgPicture.asset("assets/Icons/locationGradent.svg"),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.translate('location') ?? 'Location',
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        height: 0,
                        color: AppColors.gray50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        height: 0,
                        color: AppColors.gray50),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEditLocation,
            child: Container(
              width: 24,
              height: 24,
              child: SvgPicture.asset("assets/Icons/edit.svg"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCombinedTimeCard(
      BuildContext context, AppLocalizations? localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFE5EAF6)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTimeDetail(
            context,
            localizations?.translate('collection_time') ?? 'Collection time',
            formattedCollectionDate,
            collectionTime,
            true,
          ),
          Divider(color: Color(0xFFE5EAF6), thickness: 1, height: 24),
          buildTimeDetail(
            context,
            localizations?.translate('delivery_time') ?? 'Delivery time',
            formattedDeliveryDate,
            deliveryTime,
            false,
          ),
        ],
      ),
    );
  }

  Widget buildTimeDetail(BuildContext context, String title,
      String formattedDate, String time, bool showEditIcon) {
    final localizations = AppLocalizations.of(context);
    final lang =
        localizations?.locale.languageCode ?? 'en'; // Get current language
    // Translate AM/PM to Arabic if necessary
    final translatedTime = ValidationUtils.translateAmPm(time, lang);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showEditIcon) ...[
          Container(
            width: 24,
            height: 24,
            child: SvgPicture.asset("assets/Icons/CalendarGrad.svg"),
          ),
          const SizedBox(width: 8),
        ] else ...[
          const SizedBox(width: 32),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      height: 0,
                      color: AppColors.gray50),
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: formattedDate,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            height: 0,
                            color: AppColors.gray70),
                      ),
                    ),
                    TextSpan(
                      text: ', ',
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            height: 0,
                            color: AppColors.gray70),
                      ),
                    ),
                    TextSpan(
                      text: translatedTime,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            height: 0,
                            color: AppColors.gray60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showEditIcon)
          GestureDetector(
            onTap: onEditTime,
            child: Container(
              width: 24,
              height: 24,
              child: SvgPicture.asset("assets/Icons/edit.svg"),
            ),
          ),
      ],
    );
  }
}
