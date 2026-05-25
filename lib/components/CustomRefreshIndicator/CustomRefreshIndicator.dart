import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const CustomRefreshIndicator({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          backgroundColor: Colors.white,
          color: AppColors.gray70,
          strokeWidth: 2.0,
          child: child,
        ),
        // Positioned(
        //   top: 40,
        //   left: MediaQuery.of(context).size.width / 2 - 12,
        //   child: SvgPicture.asset(
        //     'assets/vectors/refresh_arrow.svg',
        //     height: 24,
        //     width: 24,
        //     color: AppColors.gray70,
        //   ),
        // ),
      ],
    );
  }
}
