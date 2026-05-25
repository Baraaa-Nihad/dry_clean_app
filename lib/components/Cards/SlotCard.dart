import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';

class SlotCard extends StatelessWidget {
  final String type;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final String lang; // Add a parameter to pass the current language

  const SlotCard({
    Key? key,
    required this.type,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.lang, // Require the language parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width, height, paddingHorizontal, paddingVertical;
    switch (type) {
      case 'day':
        width = 116;
        height = 78;
        paddingHorizontal = 12;
        paddingVertical = 12;
        break;
      case 'period':
        width = 86;
        height = 48;
        paddingHorizontal = 16;
        paddingVertical = 0;
        break;
      case 'time':
        width = 116;
        height = 49;
        paddingHorizontal = 12;
        paddingVertical = 12;
        break;
      default:
        width = 116;
        height = 84;
        paddingHorizontal = 12;
        paddingVertical = 12;
        break;
    }

    // Translate the label based on the language
    String translatedLabel = label;
    if (lang == 'ar') {
      if (label == 'AM') translatedLabel = 'ص';
      if (label == 'PM') translatedLabel = 'م';
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gray10 : AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.00, -0.00),
                end: Alignment(4, 0),
                colors: isSelected
                    ? [AppColors.blue, AppColors.green]
                    : [Color(0xFFE5EAF6), Color(0xFFE5EAF6)],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: Container(
              width: width,
              height: height,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: type == 'period'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: SvgPicture.asset(
                              label == 'AM'
                                  ? 'assets/Icons/Sun.svg'
                                  : 'assets/Icons/MoonInactive.svg',
                              color: AppColors.gray60,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            translatedLabel, // Use the translated label
                            style: isSelected
                                ? AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray80(context)
                                        .copyWith(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            color: AppColors.gray80),
                                  )
                                : AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray60(context)
                                        .copyWith(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            color: AppColors.gray60),
                                  ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: isSelected
                                ? AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray80(context)
                                        .copyWith(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            color: AppColors.gray80),
                                  )
                                : AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray60(context)
                                        .copyWith(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            color: AppColors.gray60),
                                  ),
                          ),
                          if (type == 'day' && subtitle != null)
                            Text(
                              subtitle!,
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
            ),
          ),
        ],
      ),
    );
  }
}
