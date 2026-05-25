import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonOrderItems extends StatelessWidget {
  const SkeletonOrderItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray20!,
      highlightColor: AppColors.gray10!,
      child: Container(
        height: 82,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.gray30!,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
