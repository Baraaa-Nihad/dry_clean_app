import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderDetails.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderFooter.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderHeader.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderItems.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class SkeletonOrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 380,
        height: 346,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFE5EAF6)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            SkeletonOrderHeader(),
            Divider(
              color: AppColors.gray10,
              thickness: 1,
              height: 1,
            ),
            // Items shimmer
            SkeletonOrderItems(),
            Divider(
              color: AppColors.gray20,
              thickness: 1,
              height: 1,
            ),
            // Details shimmer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SkeletonOrderDetails(),
              ),
            ),

            // Footer shimmer
            SkeletonOrderFooter(),
          ],
        ),
      ),
    );
  }
}
