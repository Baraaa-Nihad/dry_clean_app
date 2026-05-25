import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonOrderHeader extends StatelessWidget {
  const SkeletonOrderHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray10,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 55,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Color(0xFFE5EAF6)),
          ),
        ),
        child: Row(
          children: [
            Flexible(
              child: Container(
                width: 100,
                height: 20,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Container(
                width: 50,
                height: 20,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
