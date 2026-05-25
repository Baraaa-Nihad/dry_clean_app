import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class NoOrderWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const NoOrderWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353,
      height: 278,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 182,
            height: 182,
            child: SvgPicture.asset('assets/vectors/washingMachine.svg'),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 18.0,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray50,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
