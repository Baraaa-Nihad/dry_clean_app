import 'package:saleem_dry_clean/ui.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/store_localization.dart';

class ServiceTypeSection extends StatelessWidget {
  final String serviceType;
  final double fem;

  const ServiceTypeSection({
    Key? key,
    required this.serviceType,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 0 * fem, bottom: 12 * fem), // Added padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${localizedCatalogValue(context, serviceType)} ',
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray80),
            ),
          ),
        ],
      ),
    );
  }
}
