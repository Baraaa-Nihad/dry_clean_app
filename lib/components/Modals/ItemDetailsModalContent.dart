import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/components/Services/ServiceRow.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ImageLoader.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ItemDetailsModalContent extends StatefulWidget {
  final double fem;
  final Map<String, Map<String, dynamic>> services;
  final void Function(int, String) onValueChange;
  final String imagePath;
  final String pricePerUnit;

  const ItemDetailsModalContent({
    Key? key,
    required this.fem,
    required this.services,
    required this.pricePerUnit,
    required this.onValueChange,
    required this.imagePath,
  }) : super(key: key);

  @override
  _ItemDetailsModalContentState createState() =>
      _ItemDetailsModalContentState();
}

class _ItemDetailsModalContentState extends State<ItemDetailsModalContent> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16 * widget.fem),
        Center(
          child: ImageLoader(
            imageUrl: widget.imagePath,
            height: 226,
            width: double.infinity,
            borderRadius: 16 * widget.fem,
          ),
        ),
        SizedBox(height: 16 * widget.fem),
        Text(
          localizations.translate('service_type'),
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: AppColors.gray70,
            ),
          ),
        ),
        SizedBox(height: 8 * widget.fem),
        Column(
          children: widget.services.entries.map((entry) {
            return ServiceRow(
              pricePerUnit: widget.pricePerUnit,
              serviceName: entry.key,
              price: entry.value['price'],
              fem: widget.fem,
              onValueChange: (quantityChange, serviceName) {
                widget.onValueChange(quantityChange, serviceName);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
