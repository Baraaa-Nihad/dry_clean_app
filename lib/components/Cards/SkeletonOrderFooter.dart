import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class SkeletonOrderFooter extends StatelessWidget {
  const SkeletonOrderFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray20!,
      highlightColor: AppColors.gray10!,
      child: Container(
        width: double.infinity,
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.gray10,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 15,
                  color: AppColors.gray20,
                ),
                const SizedBox(width: 4),
                Container(
                  width: 50,
                  height: 16,
                  color: AppColors.gray20,
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 20,
                  color: AppColors.gray20,
                ),
                const SizedBox(width: 4),
                Container(
                  width: 24,
                  height: 24,
                  color: AppColors.gray20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
