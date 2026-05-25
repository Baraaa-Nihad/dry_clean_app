import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/components/Cards/CategoryCard.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/services/Providers/ServiceTypeProvider.dart';

class ServiceTypesSection extends StatelessWidget {
  final double fem;

  const ServiceTypesSection({Key? key, required this.fem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    void _handleCardPress(String serviceTypeId) {
      final serviceTypeProvider =
          Provider.of<ServiceTypeProvider>(context, listen: false);
      serviceTypeProvider.fetchServiceTypes(serviceTypeId);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          '${localizations?.translate('select_service_type') ?? 'Select service type'}',
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0 * fem,
              fontWeight: FontWeight.w600,
              height: 0,
            ),
          ),
        ),
        SizedBox(height: 20 * fem),
        Column(
          children: [
            Row(
              children: [
                CategoryCard(
                  backgroundColor: AppColors.purbleCardBackgourd,
                  iconColor: AppColors.prpuleCard,
                  title: '${localizations?.translate('Laundry') ?? 'Laundry'}',
                  icon: SvgPicture.asset('assets/vectors/Tshirt.svg'),
                  fem: fem,
                  generalUnit: "item",
                  serviceTypeId: '1', // Use the actual service type ID here
                  onPressed: () => _handleCardPress(
                      '1'), // Use the actual service type ID here
                ),
                SizedBox(width: 16 * fem),
                CategoryCard(
                  backgroundColor: AppColors.greenCardBackgourd,
                  iconColor: AppColors.greenCard,
                  title: '${localizations?.translate('Carpets') ?? 'Carpets'}',
                  icon: SvgPicture.asset('assets/Icons/Carpets.svg'),
                  fem: fem,
                  generalUnit: "Square meter",
                  serviceTypeId: '2', // Use the actual service type ID here
                  onPressed: () => _handleCardPress(
                      '2'), // Use the actual service type ID here
                ),
              ],
            ),
            SizedBox(height: 16 * fem),
            Row(
              children: [
                CategoryCard(
                  backgroundColor: AppColors.blueCardBackgourd,
                  iconColor: AppColors.blueCard,
                  title:
                      '${localizations?.translate('Curtains') ?? 'Curtains'}',
                  icon: SvgPicture.asset('assets/Icons/Bedding.svg'),
                  fem: fem,
                  generalUnit: "Square meter",
                  serviceTypeId: '4', // Use the actual service type ID here
                  onPressed: () => _handleCardPress(
                      '3'), // Use the actual service type ID here
                ),
                SizedBox(width: 16 * fem),
                CategoryCard(
                  backgroundColor: AppColors.orangeCardBackgourd,
                  iconColor: AppColors.orangeCard,
                  title: '${localizations?.translate('Bedding') ?? 'Bedding'}',
                  icon: SvgPicture.asset('assets/Icons/Bedding.svg'),
                  fem: fem,
                  generalUnit: "item",
                  serviceTypeId: '3', // Use the actual service type ID here
                  onPressed: () => _handleCardPress(
                      '4'), // Use the actual service type ID here
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
