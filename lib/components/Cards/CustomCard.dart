import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Cards/VerifiedBadge.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

enum HeightType {
  normal,
  big,
}

class CustomCard extends StatelessWidget {
  final bool leadingIcon;
  final String? leadingIconPath;
  final String title;
  final String? subtitle;
  final bool trailingIcon;
  final String? trailingIconPath;
  final VoidCallback onTap;
  final HeightType heightType;
  final String? placeholder;
  final VoidCallback? onTrailingIconTap;
  final bool isVerified;

  const CustomCard({
    Key? key,
    required this.leadingIcon,
    this.leadingIconPath,
    required this.title,
    this.subtitle,
    required this.trailingIcon,
    this.trailingIconPath,
    required this.onTap,
    required this.heightType,
    this.placeholder,
    this.onTrailingIconTap,
    this.isVerified = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    double cardHeight = heightType == HeightType.big ? 80 : 56;
    double iconTextGap = heightType == HeightType.big ? 16 : 12;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x07000000),
              blurRadius: 5,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leadingIcon && leadingIconPath != null)
                  SvgPicture.asset(
                    leadingIconPath!,
                    width: 24,
                    height: 24,
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray70),
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              height: 0,
                              color: AppColors.gray80),
                        ),
                      )
                    else if (placeholder != null)
                      Text(
                        placeholder!,
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              height: 0,
                              color: AppColors.gray40),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (trailingIcon)
              Row(
                children: [
                  if (isVerified)
                    Row(
                      children: [
                        VerifiedBadge(),
                        const SizedBox(width: 4),
                      ],
                    ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onTrailingIconTap,
                    child: Transform(
                      alignment: Alignment.center,
                      transform:
                          isRtl ? Matrix4.rotationY(3.14) : Matrix4.identity(),
                      child: trailingIconPath != null
                          ? SvgPicture.asset(
                              trailingIconPath!,
                              width: 24,
                              height: 24,
                            )
                          : Icon(Icons.chevron_right, size: 24),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
