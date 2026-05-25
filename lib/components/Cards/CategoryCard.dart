// lib/components/Cards/CategoryCard.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CategoryCard extends StatelessWidget {
  final Color backgroundColor;
  final String generalUnit;
  final Color iconColor;
  final String title;
  final Widget icon;
  final double fem;
  final String serviceTypeId;
  final VoidCallback onPressed;

  const CategoryCard({
    Key? key,
    required this.backgroundColor,
    required this.generalUnit,
    required this.iconColor,
    required this.title,
    required this.icon,
    required this.fem,
    required this.serviceTypeId,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          NavigatorService.navigateTo(
            RouteNames.service,
            arguments: {
              'serviceName': title,
              'generalUnit': generalUnit,
              'pricePerUnit': generalUnit, // Adjust if necessary
              'serviceTypeId': serviceTypeId,
            },
          );
        },
        child: Container(
          height: 182 * fem,
          padding: EdgeInsets.all(20 * fem),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: iconColor.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(20 * fem),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60 * fem,
                height: 60 * fem,
                decoration: ShapeDecoration(
                  color: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60 * fem),
                  ),
                ),
                child: Center(child: icon),
              ),
              SizedBox(height: 20 * fem),
              Text(
                title,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0 * fem,
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
