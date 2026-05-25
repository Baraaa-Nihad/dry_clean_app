import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class ShimmerCard extends StatelessWidget {
  final double fem;

  const ShimmerCard({Key? key, required this.fem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 380 * fem,
        padding: EdgeInsets.all(16 * fem),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Color(0xFFE5EAF6),
            ),
            borderRadius: BorderRadius.circular(16 * fem),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24 * fem,
                  height: 24 * fem,
                  color: Colors.white,
                ),
                SizedBox(width: 16 * fem),
                Container(
                  width: 200 * fem,
                  height: 24 * fem,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Container(
                  width: 75,
                  height: 30,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 12 * fem),
            Container(
              width: 280 * fem,
              height: 20 * fem,
              color: Colors.white,
            ),
            SizedBox(height: 4 * fem),
            Container(
              width: 280 * fem,
              height: 20 * fem,
              color: Colors.white,
            ),
            SizedBox(height: 12 * fem),
            Divider(
              color: AppColors.gray20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 80 * fem,
                  height: 24 * fem,
                  color: Colors.white,
                ),
                Spacer(),
                Container(
                  width: 40 * fem,
                  height: 24 * fem,
                  color: Colors.white,
                ),
                SizedBox(width: 12 * fem),
                Container(
                  width: 60 * fem,
                  height: 24 * fem,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
