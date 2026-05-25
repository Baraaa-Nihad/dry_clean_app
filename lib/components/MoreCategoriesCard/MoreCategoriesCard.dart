import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class MoreCategoriesCard extends StatelessWidget {
  final double fem;

  const MoreCategoriesCard({Key? key, required this.fem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * fem),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Center(
        child: Text(
          'More\nCategories',
          textAlign: TextAlign.center,
          style: AppTextStyles.poppinsBold.copyWith(
            fontSize: 14 * fem,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
