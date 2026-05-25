import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonOrderDetails extends StatelessWidget {
  const SkeletonOrderDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray20!,
      highlightColor: AppColors.gray10!,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                width: double.infinity,
                height: 20,
                color: Colors.grey[300],
              ),
            );
          }),
        ),
      ),
    );
  }
}
