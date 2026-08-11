import 'package:saleem_dry_clean/ui.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/store_localization.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final double fem;
  final bool isFirst; // Add this parameter

  const CategorySection({
    Key? key,
    required this.title,
    required this.fem,
    this.isFirst = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 12 * fem),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localizedCatalogValue(context, title)} ',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      height: 0,
                      color: AppColors.gray80),
                ),
              ),
              if (isFirst) // Conditionally show the text
                Text(
                  '${localizations.translate('swipe_to_delete')} ',
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray40),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8)
      ],
    );
  }
}
