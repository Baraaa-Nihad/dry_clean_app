import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerOrderHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray20!,
      highlightColor: AppColors.gray10!,
      child: Container(
        height: 62,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray10,
          border: Border(
            bottom: BorderSide(width: 1, color: AppColors.gray20),
          ),
        ),
      ),
    );
  }
}
